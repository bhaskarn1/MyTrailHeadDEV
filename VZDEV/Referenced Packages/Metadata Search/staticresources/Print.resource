@page {
    margin-left: 0.8cm;
    margin-right: 0.8cm;
    margin-top: 0.8cm;
    margin-bottom: 0.8cm;
    @bottom-left {
        font-family: Verdana, Arial, Helvetica, sans-serif;
        font-size: 8pt;
        content: "Metadata Search Results";
    }
    @bottom-center {
        font-family: Verdana, Arial, Helvetica, sans-serif;
        font-size: 8pt;
    }
    @bottom-right {
        font-family: Verdana, Arial, Helvetica, sans-serif;
        font-size: 8pt;
        content: "Page " counter(page) " of " counter(pages);
    }
}
table {
    page-break-after: auto;
    border-collapse: collapse;
}
tr {
    page-break-inside: avoid;
    page-break-after: auto;
}
td {
    page-break-inside: avoid;
    page-break-after: auto;
}
thead {
    display: table-header-group;
}
tfoot {
    display: table-footer-group;
}
.Outerdivclass {
    page-break-inside: avoid;
    page-break-after: auto;
}