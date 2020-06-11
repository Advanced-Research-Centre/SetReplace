<|
  "causalGraph" -> <|
    "init" -> (
      Attributes[Global`testUnevaluated] = {HoldAll};
      Global`testUnevaluated[args___] := SetReplace`PackageScope`testUnevaluated[VerificationTest, args];
      Global`$testSystems = SetReplace`PackageScope`$testSystems;
    ),
    "tests" -> {
      VerificationTest[
        AcyclicGraphQ[WolframModel[#1, #2, #6, "CausalGraph"]]
      ] & @@@ $testSystems,

      VerificationTest[
        LoopFreeGraphQ[WolframModel[#1, #2, #6, "CausalGraph"]]
      ] & @@@ $testSystems,

      VerificationTest[
        VertexCount[WolframModel[#1, #2, #6, "CausalGraph"]],
        WolframModel[#1, #2, #6, "EventsCount"]
      ] & @@@ $testSystems,

      Table[With[{seed = seed}, {
        VerificationTest[
          SeedRandom[seed]; AcyclicGraphQ[WolframModel[#1, #2, #6, "CausalGraph", "EventOrderingFunction" -> "Random"]]
        ] & @@@ $testSystems,

        VerificationTest[
          SeedRandom[seed]; LoopFreeGraphQ[WolframModel[#1, #2, #6, "CausalGraph", "EventOrderingFunction" -> "Random"]]
        ] & @@@ $testSystems,

        VerificationTest[
          SeedRandom[seed]; VertexCount[WolframModel[#1, #2, #6, "CausalGraph", "EventOrderingFunction" -> "Random"]],
          SeedRandom[seed]; WolframModel[#1, #2, #6, "EventsCount", "EventOrderingFunction" -> "Random"]
        ] & @@@ $testSystems
      }], {seed, 1534, 1634}]
    }
  |>
|>
