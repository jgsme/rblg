require! {
  fs: {readFileSync, writeFileSync}
}

js-path = "#{process.env.npm_package_config_DEST}/index.js"
target =
  readFileSync js-path
    .toString!
URL =
  readFileSync ".firebaseURL"
    .toString!
    .replace /\n/g, ''
writeFileSync do
  js-path
  target.replace /FIREBASE_URL/g, URL
