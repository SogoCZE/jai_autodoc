Plugin :: Metaprogram_Plugin;

Modules :: Table(string, [..]*Code_Declaration);

Autodoc_Plugin :: struct {
    #as using base: Plugin;
    should_run := true;

    modules: Modules;
}

get_plugin :: () -> *Plugin {
    p := New(Autodoc_Plugin);

    p.message  = message;
    p.shutdown = shutdown;
    p.add_source = add_source;
    p.before_intercept = before_intercept;

    init(*p.modules);

    return p;   
}

add_source :: (_p: *Metaprogram_Plugin) {
    p := cast(*Autodoc_Plugin) _p;
}

before_intercept :: (_p: *Plugin, flags: *Intercept_Flags) {
    p := cast(*Autodoc_Plugin) _p;

    options := get_build_options(p.workspace);
    options.output_type = .NO_OUTPUT; // Do not output any binary files. 
    set_build_options(options, p.workspace);
}

message :: (_p: *Plugin, message: *Message) {
    p := cast(*Autodoc_Plugin) _p;
    o := get_build_options(p.workspace);

    // Generate Doc when the compiler is complete.
    if message.kind == .COMPLETE {
        generate(p.modules);
        return;
    }

    if message.kind != .TYPECHECKED return;

    tc := cast(*Message_Typechecked) message;

    for typechecked: tc.declarations {
        decl := typechecked.expression;

        if !(decl.flags & .IS_GLOBAL) || !decl.expression continue;
        if !decl.location.enclosing_load || !decl.location.enclosing_load.enclosing_import continue;

        module_name := decl.location.enclosing_load.enclosing_import.module_name;
        module := find_or_add(*p.modules, module_name);

        array_add(module, decl);
    }

}

shutdown :: (_p: *Plugin) {
    p := cast(*Autodoc_Plugin) _p;
    deinit(*p.modules);
    free(p);
}

#load "../generator.jai";

#import "Basic";
#import "String";
#import "Compiler";
#import "Process";
#import "Hash_Table";
#import "File";
#import "File_Utilities";