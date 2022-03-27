const { platform } = require("os");

const getPlatform = async () => {
    const name = {
        win32: "windows",
        linux: "linux",
        darwin: "macos",
    }[platform()];
    if (!name) throw Error("Unsupported platform");

    return name;
};

module.exports = { getPlatform };
