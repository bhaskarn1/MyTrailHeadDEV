@page {
    size: landscape;
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
@media print
{
  table { page-break-after:auto }
  tr    { page-break-inside:avoid; page-break-after:auto }
  td    { page-break-inside:avoid; page-break-after:auto }
  thead { display:table-header-group }
  tfoot { display:table-footer-group }
}
table {
    page-break-inside: auto;
    border-collapse: collapse;
    width:100%;
    font-size: 11pt;
}
tr {
    page-break-inside: avoid;
    page-break-after: auto;
    height: auto;
}
thead {
    display: table-header-group
}
tfoot {
    display: table-footer-group
}
div td {
    border: 0.4px solid black;
    width: auto;
    height: auto;
    overflow: auto;
    padding: 5px;
    font-size: 0.8em;
}
div td.shrink {
    width: 10%;
}
/*
div.bPageBlock .list {
    width : 70% ;
}
*/
div td.expand {
    height: 99%
}
div th {
    border: 0.4px solid black;
    width: 10%;
    padding: 5px;
    font-size: 0.9em;
}
div.pbHeader {
    font-size: 1.2em;
    border-left: 0.4px solid black;
    width: 100%;
    border-right: 0.4px solid black;
    width: 100%;
    border-top: 0.4px solid black;
    width: 100%;
    border-bottom: 0.4px solid black;
    width: 100%;
}
div img {
    padding-top: 2px;
}
div.MetadataTitle {
   font-size:   20px;
   margin-top : 35px !important  ;
   text-align: center;
}
div.MetadataFirstTitle {
   margin-left: 250px ; 
   margin-top : 175px !important  ;
   padding-top : 5px;
   font-size:      50px;
}
.MatchesFound {
   font-size:      30px;
   margin-top : 150px !important  ;
   text-align: center;
   margin-left : 40px;
}
.MetadataLogo {
     margin-top: 10px;
     padding-left : 10px;
}
body {
    font-family: Verdana, Geneva, sans-serif;
}
span.MyPbHeader {
    margin-left:5px;
    font-size: 0.9em;
}
span.MyPbHeader1 {
    margin-left:5px;
    font-size: 0.9em;
    font-size: smaller;
}
div.NOMatchDiv {
    margin-Top: 10px;
    font-family: Verdana, Geneva, sans-serif;
/**    border: 0.4px solid black; **/
    width: 100%;
    font-size: 0.9em;
}
div.pbBody {
    margin-Top: 10px;
    height: auto;
    overflow: inherit;
}
div small {
    /*font-family: Lucida Console, Monaco, monospace*/
    font-family: Verdana, Geneva, sans-serif;
    font-size: 0.6em;
}
div.bPageBlock {
    margin-bottom: 30px;
}
.bPageBlock .list {
    width: 100%;
}
a {
    color:black;
}
.Outerdivclass {
    width: 99%;
}
.message .messageTable tr td:first-child {
    display: none;
}
.message .messageTable .messageCell {
    display: none;
}