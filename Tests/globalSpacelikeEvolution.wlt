<|
  "globalSpacelikeEvolution" -> <|
    "init" -> (
      Attributes[Global`testUnevaluated] = {HoldAll};
      Global`testUnevaluated[args___] := SetReplace`PackageScope`testUnevaluated[VerificationTest, args];
      Global`$testSystems = SetReplace`PackageScope`$testSystems;

      (* Assign variables that ToPatternRules would use to confuse setSubstitutionSystem as much as possible. *)
      v1 = v2 = v3 = v4 = v5 = 1;
    ),
    "tests" -> {
      (* Fixed number of events same seed consistentcy *)

      VerificationTest[
        SeedRandom[1655]; WolframModel[#1, #2, <|"MaxEvents" -> #5|>, "EventOrderingFunction" -> "Random"],
        SeedRandom[1655]; WolframModel[#1, #2, <|"MaxEvents" -> #5|>, "EventOrderingFunction" -> "Random"]
      ] & @@@ $testSystems,

      (* Fixed number of events different seeds difference *)

      VerificationTest[
        (SeedRandom[1655]; WolframModel[#1, #2, <|"MaxEvents" -> #5|>, "EventOrderingFunction" -> "Random"]) =!=
          (SeedRandom[1656]; WolframModel[#1, #2, <|"MaxEvents" -> #5|>, "EventOrderingFunction" -> "Random"])
      ] & @@@ Select[$testSystems, #[[7]] =!= "sequential" &],

      (* Fixed number of generations same seed consistentcy *)

      VerificationTest[
        SeedRandom[1655]; WolframModel[#1, #2, #6, "EventOrderingFunction" -> "Random"],
        SeedRandom[1655]; WolframModel[#1, #2, #6, "EventOrderingFunction" -> "Random"]
      ] & @@@ $testSystems,

      (* Correct number of generations is obtained *)

      VerificationTest[
        SeedRandom[1655];
          WolframModel[
            #1, #2, #6, {"TotalGenerationsCount", "MaxCompleteGeneration"}, "EventOrderingFunction" -> "Random"],
        {#6, #6}
      ] & @@@ $testSystems,

      (* Fixed number of generations different seeds difference *)
      (* Even though final sets might be the same for some of these systems, different evaluation order will make *)
      (* evolution objects different *)

      VerificationTest[
        (SeedRandom[1655]; WolframModel[#1, #2, #6, "EventOrderingFunction" -> "Random"]) =!=
          (SeedRandom[1656]; WolframModel[#1, #2, #6, "EventOrderingFunction" -> "Random"])
      ] & @@@ Select[$testSystems, #[[7]] =!= "sequential" &]
    }
  |>
|>
