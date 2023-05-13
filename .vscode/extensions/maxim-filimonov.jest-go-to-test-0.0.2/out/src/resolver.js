"use strict";
function getRelated(file) {
    if (isSpec(file)) {
        return specToCode(file);
    }
    else {
        return codeToSpec(file);
    }
}
exports.getRelated = getRelated;
function isSpec(file) {
    return file.indexOf(".spec") > -1 || file.indexOf(".test") > -1;
}
exports.isSpec = isSpec;
function codeToSpec(file) {
    if (file.includes(".js"))
        return file.replace(".js", ".test.js");
    if (file.includes(".ts"))
        return file.replace(".ts", ".test.ts");
}
exports.codeToSpec = codeToSpec;
function specToCode(file) {
    if (file.includes(".js"))
        return file.replace(".test.js", ".js");
    if (file.includes(".ts"))
        return file.replace(".test.ts", ".ts");
}
exports.specToCode = specToCode;
//# sourceMappingURL=resolver.js.map