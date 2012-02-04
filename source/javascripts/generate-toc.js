// Generate the table of contents for a page, using the jQuery
// TOC plugin.
//
// Parameters:
//
// insertBefore: selector for jQuery element before which to insert TOC <div>.
//               The first matching element is used.
// heading:      heading, if any

function generateTOC(insertBefore, heading) {
  var container = $("<div id='tocBlock'></div>");
  var div = $("<div id='toc'></div>");
  var content = $(insertBefore).first();

  if (heading != undefined && heading != null) {
    container.append('<span class="tocHeading">' + heading + '</span>');
  }

  div.tableOfContents(content);
  container.append(div);
  container.insertBefore(insertBefore);
}