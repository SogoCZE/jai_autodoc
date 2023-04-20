// @SPEED: @TODO: Put all this code into dynamic lib (like in Jails)

TITLE :: "Jai Autodoc";

append_html :: (builder: *String_Builder, html: string, vars: ..Any) {
    if vars.count == 0 {
        append(builder, html);
        return;
    }

    append(builder, tprint(html, ..vars));
}

generate :: (modules: Modules) {
    builder: String_Builder;
    init_string_builder(*builder);
    defer reset(*builder);

    append_html(*builder, #string HTML 
        <!DOCTYPE html>
        <html lang="en"> 
    HTML);

    head(*builder, TITLE);

    sidebar(*builder, modules);

    append(*builder, "<section>Content</section>");

    append(*builder, "</html>");

    make_directory_if_it_does_not_exist("../output/modules", recursive=true);

    copy_file("../assets/script.js", "../output/script.js");
    copy_file("../assets/style.css", "../output/style.css");

    write_entire_file("../output/index.html", *builder);

    for decls, module: modules {
        if module.count == 0 continue;
        generate_module_file(module, decls, modules);
    }
}

head :: (builder: *String_Builder, title: string) {
    append_html(builder, #string HTML
    <head>
        <meta charset="UTF-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;700&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="style.css">
        <script src="script.js" defer async></script>
        <title>%</title>
    </head>
    HTML, title);
}

sidebar :: (builder: *String_Builder, modules: Modules, active := "") {
    append_html(builder, #string HTML
        <aside class="modules">
            <h1><a href="/">%</a></h1>
            <ul>
    HTML, TITLE);

    for decls, module: modules {
        if module.count == 0 continue;
        append_html(builder, #string HTML
            <li class="%""><a href="%.html">%</a></li>
        HTML, ifx module == active "active" else "", module, module);
    }

    append_html(builder, "</ul></aside>");
}

generate_module_file :: (module: string, decls: []*Code_Declaration, modules: Modules) {
    builder: String_Builder;
    init_string_builder(*builder);
    defer reset(*builder);

    head(*builder, module);
    sidebar(*builder, modules, module);

    generate_module_content(*builder, module, decls);

    append(*builder, "</html>");


    write_entire_file(tprint("../output/%.html", module), *builder);
}

generate_module_content :: (builder: *String_Builder, module: string, decls: []*Code_Declaration) {
    append_html(builder, #string HTML
        <section>
            <h2>Module %</h2>
    HTML, module);

    for decl: decls {
        append_html(builder, #string HTML
            <h3 id="%1"><a href="#%1">%1</a></h3>
        HTML, decl.name, decl.expression.kind);
    }

    append_html(builder, "</section>");
}