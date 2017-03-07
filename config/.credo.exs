%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["lib/"],
        excluded: []
      },
      checks: [
        {Credo.Check.Readability.MaxLineLength, max_length: 120},
        {Credo.Check.Readability.ModuleDoc, false},
        {Credo.Check.Design.AliasUsage, false},
        {Credo.Check.Design.AliasUsage, false},
        {Credo.Check.Consistency.SpaceInParentheses, false}
      ]
    }
  ]
}
