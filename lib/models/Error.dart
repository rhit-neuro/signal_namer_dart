class ErrorObj {
  var content;
  var line;

  var fileName;

  var type;

  var expanded;
  var fullLine;
  ErrorObj({
    this.content,
    this.line,
    this.fileName,
    this.type,
    this.expanded = false,
    this.fullLine,
  });
}
