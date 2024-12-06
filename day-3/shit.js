console.log(
  `Part 1 total: ${Array.from(
    require("fs")
      .readFileSync("input.txt", "utf-8")
      .matchAll(/mul\((\d+),(\d+)\)/g),
  )
    .map(([, a, b]) => a * b)
    .reduce((a, b) => a + b, 0)}`,
);

console.log(
  `Part 2 total: ${
    Array.from(
      require("fs")
        .readFileSync("input.txt", "utf-8")
        .matchAll(/mul\((\d+),(\d+)\)|do\(\)|don't\(\)/g),
    ).reduce(
      ({ enabled, total }, regexMatch) => {
        const [match, a, b] = regexMatch;
        if (match === "do()") return { enabled: true, total };
        if (match === "don't()") return { enabled: false, total };
        if (enabled) return { enabled, total: total + a * b };
        return { enabled, total };
      },
      { enabled: true, total: 0 },
    ).total
  }`,
);
