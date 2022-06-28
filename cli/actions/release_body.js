const getReleaseBody = async () => {
    const { GITHUB_REPOSITORY, RELEASE_TAG } = process.env;

    return `
Changelogs: https://github.com/${GITHUB_REPOSITORY}/commits/${RELEASE_TAG}
`.trim();
};

module.exports = { getReleaseBody };
