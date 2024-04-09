var now = new Date();

var dateFormatter = new Intl.DateTimeFormat('en-US', {
  hour: '2-digit',
  minute: '2-digit',
  month: 'short',
  day: '2-digit',
  year: 'numeric'
});
var formattedDate = dateFormatter.format(now);
output.currentDate = formattedDate   // returns 'JOHN'
console.log(formattedDate)