<|
  "causalGraph" -> <|
    "init" -> (
      Attributes[Global`testUnevaluated] = {HoldAll};
      Global`testUnevaluated[args___] := SetReplace`PackageScope`testUnevaluated[VerificationTest, args];

      consistentQ = Function[{evolution},
        AcyclicGraphQ[evolution["CausalGraph"]] &&
        LoopFreeGraphQ[evolution["CausalGraph"]] &&
        VertexCount[evolution["CausalGraph"]] === evolution["EventsCount"]];

      $eventSelectionFunctions = {"GlobalSpacelike", None};
      methods["GlobalSpacelike"] = {"LowLevel", "Symbolic"};
      methods[None] = {"LowLevel"};

      (* rule, init, global-spacelike low-level events, global-spacelike symbolic events, match-all events *)
      $systems = {
        {{{0, 1}} -> {{0, 2}, {2, 1}}, {{0, 1}}},
        {{{{1}} -> {{1}}}, {{1}}},
        {{{{1}} -> {{2}}}, {{1}}},
        {{{{1}} -> {{2}, {1, 2}}}, {{1}}},
        {{{{1}} -> {{1}, {2}, {1, 1}}}, {{1}}},
        {{{{1}} -> {{1}, {2}, {1, 2}}}, {{1}}},
        {{{{1}} -> {{1}, {2}, {1, 3}}}, {{1}}},
        {{{{1}} -> {{2}, {2}, {1, 2}}}, {{1}}},
        {{{{1}} -> {{2}, {3}, {1, 2}}}, {{1}}},
        {{{{1}} -> {{2}, {3}, {1, 2, 4}}}, {{1}}},
        {{{{1}} -> {{2}, {2}, {2}, {1, 2}}}, {{1}}},
        {{{{1}} -> {{2}, {1, 2}}}, {{1}, {1}, {1}}},
        {{{{1, 2}} -> {{1, 3}, {2, 3}}}, {{1, 1}}},
        {{{0, 1}, {0, 2}, {0, 3}} -> {{4, 5}, {5, 4}, {4, 6}, {6, 4}, {5, 6}, {6, 5}, {4, 1}, {5, 2}, {6, 3}},
         {{0, 1}, {0, 2}, {0, 3}}},
        {{{0, 1}, {0, 2}, {0, 3}} -> {{4, 5}, {5, 4}, {4, 6}, {6, 4}, {5, 6}, {6, 5}, {4, 1}, {5, 2}, {6, 3}},
         {{0, 0}, {0, 0}, {0, 0}}},
        {{{0, 1}, {0, 2}, {0, 3}} ->
           {{4, 5}, {5, 4}, {4, 6}, {6, 4}, {5, 6}, {6, 5}, {4, 1}, {5, 2}, {6, 3}, {1, 6}, {3, 4}},
         {{0, 1}, {0, 2}, {0, 3}}},
        {{{0, 1}, {0, 2}, {0, 3}} ->
           {{4, 5}, {5, 4}, {4, 6}, {6, 4}, {5, 6}, {6, 5}, {4, 1}, {5, 2}, {6, 3}, {1, 6}, {3, 4}},
         {{0, 0}, {0, 0}, {0, 0}}},
        {{{1, 2}, {1, 3}, {1, 4}} -> {{2, 3}, {2, 4}, {3, 3}, {3, 5}, {4, 5}}, {{1, 1}, {1, 1}, {1, 1}}},
        {{{1, 2, 3}, {4, 5, 6}, {1, 4}, {4, 1}} ->
           {{2, 7, 8}, {3, 9, 10}, {5, 11, 12}, {6, 13, 14}, {7, 11}, {8, 10}, {9, 13}, {10, 8}, {11, 7}, {12, 14},
            {13, 9}, {14, 12}},
         {{1, 2, 3}, {4, 5, 6}, {1, 4}, {2, 5}, {3, 6}, {4, 1}, {5, 2}, {6, 3}}},
        {{{1, 2, 2}, {3, 4, 2}} -> {{2, 5, 5}, {5, 3, 2}, {5, 4, 6}, {7, 4, 5}}, {{1, 1, 1}, {1, 1, 1}}},
        {{{1, 1, 2}} -> {{3, 2, 2}, {3, 3, 3}, {3, 3, 4}}, {{1, 1, 1}}},
        {{{{1, 2}, {1, 3}, {1, 4}} -> {{2, 3}, {3, 4}, {4, 5}, {5, 2}, {5, 4}}}, {{1, 1}, {1, 1}, {1, 1}}},
        {<|"PatternRules" -> {a_, b_} :> a + b|>, {1, 2, 5, 3, 6}}
      };
    ),
    "tests" -> {
      Function[{verificationFunction, rule, init, stepsSpec, method, eventSelectionFunction}, {
        VerificationTest[
          verificationFunction[WolframModel[rule,
                                            init,
                                            stepsSpec,
                                            "EventSelectionFunction" -> eventSelectionFunction,
                                            Method -> method]]
        ],

        Function[{seed},
          VerificationTest[
            SeedRandom[seed];
            verificationFunction[WolframModel[rule,
                                              init,
                                              stepsSpec,
                                              "EventSelectionFunction" -> eventSelectionFunction,
                                              "EventOrderingFunction" -> "Random"]]
          ]
        ] /@ Range[1534, 1544]
      }] @@@ Catenate[Table[
        {consistentQ,
         system[[1]],
         system[[2]],
         system[[Switch[{eventSelectionFunction, method},
           {"GlobalSpacelike", "LowLevel"}, 3,
           {"GlobalSpacelike", "Symbolic"}, 4,
           {None, _}, 5]]],
         method,
         eventSelectionFunction},
        {eventSelectionFunction, $eventSelectionFunctions},
        {method, methods[eventSelectionFunction]},
        {system, $systems}]]
    }
  |>
|>
