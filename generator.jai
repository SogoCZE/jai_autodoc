
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

    sidebar(*builder, TITLE, modules);

    append(*builder, "<section>Content</section>");

    append(*builder, "</html>");

    make_directory_if_it_does_not_exist("../output");

    copy_file("../assets/script.js", "../output/script.js");
    copy_file("../assets/style.css", "../output/style.css");

    write_entire_file("../output/index.html", *builder);
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

sidebar :: (builder: *String_Builder, title: string, modules: Modules) {
    append_html(builder, #string HTML
        <aside>
            <h1>%</h1>
    HTML, title);

    for decls, module: modules {
        module_menu(builder, module, decls);
    }

    append_html(builder, "</aside>");
}

module_menu :: (builder: *String_Builder, module: string, decls: []*Code_Declaration) {
    append_html(builder, #string HTML
        <article class="module">
            <h2>%</h2>
            <ul>
    HTML, module);

    for decl: decls {
        append_html(builder, #string HTML
            <li>%</li>
        HTML, decl.name);
    }

    append(builder, "</ul></article>");
}