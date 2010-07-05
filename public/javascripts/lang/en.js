/* I edited the default locale in datepicer.js directly instead of in this language file.
We want firstDayOfWeek to be Sunday (=1).
This plugin doesn't seem to get the firstDayOfWeek from the locale file (even though it does get the rest)

~Casey
*/

var fdLocale = {
                fullMonths:["January","February","March","April","May","June","July","August","September","October","November","December"],
                monthAbbrs:["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],
                fullDays:  ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"],
                dayAbbrs:  ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"],
                titles:    ["Previous month","Next month","Previous year","Next year", "Today", "Open Calendar", "wk", "Week [[%0%]] of [[%1%]]", "Week", "Select a date", "Click \u0026 Drag to move", "Display \u201C[[%0%]]\u201D first", "Go to Today\u2019s date", "Disabled date:"],
                firstDayOfWeek:1,
};
try { datePickerController.loadLanguage(); } catch(err) {}

