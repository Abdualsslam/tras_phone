const fs = require("fs");
const files = [
  "admin/src/pages/settings/SettingsPage.tsx",
  "admin/src/pages/content/ContentPage.tsx",
  "admin/src/pages/content/EducationalContentPage.tsx",
];
const old =
  'onError: () => toast.error("\u062D\u062F\u062B \u062E\u0637\u0623"),';
const rep = "onError: (error) => toast.error(getErrorMessage(error)),";
files.forEach((f) => {
  let c = fs.readFileSync(f, "utf8");
  const count = c.split(old).length - 1;
  c = c.split(old).join(rep);
  fs.writeFileSync(f, c, "utf8");
  console.log(f + ": replaced " + count);
});
