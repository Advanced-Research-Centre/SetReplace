Package["SetReplace`"]

PackageScope["testUnevaluated"]
PackageScope["testSymbolLeak"]
PackageScope["checkGraphics"]
PackageScope["graphicsQ"]
PackageScope["$testSystems"]

(* VerificationTest should not directly appear here, as it is replaced by test.wls into other heads during evaluation.
    Use testHead argument instead. *)

(* It is necessary to compare strings because, i.e.,
    MatchQ[<|x -> 1|>, HoldPattern[<|x -> 1|>]] returns False. *)
Attributes[testUnevaluated] = {HoldAll};
testUnevaluated[testHead_, input_, messages_, opts___] :=
  testHead[
    ToString[FullForm[input]],
    StringReplace[ToString[FullForm[Hold[input]]], StartOfString ~~ "Hold[" ~~ expr___ ~~ "]" ~~ EndOfString :> expr],
    messages,
    opts];

Attributes[testSymbolLeak] = {HoldAll};
testSymbolLeak[testHead_, expr_, opts___] :=
  testHead[
    Module[{Global`before, Global`after},
      expr; (* symbols might get created at the first run due to initialization *)
      Global`before = Length[Names["*`*"]];
      expr;
      Global`after = Length[Names["*`*"]];
      Global`after - Global`before
    ],
    0,
    opts
  ];

(* UsingFrontEnd is necessary while running from wolframscript *)
(* Flashes a new frontend window momentarily, but that is ok, because this function is mostly for use in the CI *)
frontEndErrors[expr_] := UsingFrontEnd @ Module[{notebook, result},
  notebook = CreateDocument[ExpressionCell[expr]];
  SelectionMove[notebook, All, Notebook];
  result = MathLink`CallFrontEnd[FrontEnd`GetErrorsInSelectionPacket[notebook]];
  NotebookClose[notebook];
  result
]

checkGraphics::frontEndErrors := "``";

checkGraphics[graphics_] := (
  Message[checkGraphics::frontEndErrors, #] & /@ Flatten[frontEndErrors[graphics]];
  graphics
)

graphicsQ[graphics_] := Head[graphics] === Graphics && frontEndErrors[graphics] === {}

(* Once we have enumeration functionality, we can autogenerate this.
   Until then, the list is here because it is used in multiple tests.
   The format is
    {rule, WL events, WL generations, C++ events, C++ generations, whether the system grows exponentially or not} *)
$testSystems = {
  {{{0, 1}} -> {{0, 2}, {2, 1}}, {{0, 1}}, 100, 6, 1000, 7, "branching"},
  {{{{1}} -> {{1}}}, {{1}}, 100, 100, 1000, 1000, "sequential"},
  {{{{1}} -> {{2}}}, {{1}}, 100, 100, 1000, 1000, "sequential"},
  {{{{1}} -> {{2}, {1, 2}}}, {{1}}, 100, 100, 1000, 1000, "sequential"},
  {{{{1}} -> {{1}, {2}, {1, 1}}}, {{1}}, 100, 6, 1000, 7, "branching"},
  {{{{1}} -> {{1}, {2}, {1, 2}}}, {{1}}, 100, 6, 1000, 7, "branching"},
  {{{{1}} -> {{1}, {2}, {1, 3}}}, {{1}}, 100, 6, 1000, 7, "branching"},
  {{{{1}} -> {{2}, {2}, {1, 2}}}, {{1}}, 100, 6, 1000, 7, "branching"},
  {{{{1}} -> {{2}, {3}, {1, 2}}}, {{1}}, 100, 6, 1000, 7, "branching"},
  {{{{1}} -> {{2}, {3}, {1, 2, 4}}}, {{1}}, 100, 6, 1000, 7, "branching"},
  {{{{1}} -> {{2}, {2}, {2}, {1, 2}}}, {{1}}, 100, 4, 1000, 5, "branching"},
  {{{{1}} -> {{2}, {1, 2}}}, {{1}, {1}, {1}}, 100, 34, 1000, 400, "branching"},
  {{{{1, 2}} -> {{1, 3}, {2, 3}}}, {{1, 1}}, 100, 6, 1000, 7, "branching"},
  {{{0, 1}, {0, 2}, {0, 3}} -> {{4, 5}, {5, 4}, {4, 6}, {6, 4}, {5, 6}, {6, 5}, {4, 1}, {5, 2}, {6, 3}},
    {{0, 1}, {0, 2}, {0, 3}},
    30, 3, 100, 4,
    "branching"},
  {{{0, 1}, {0, 2}, {0, 3}} -> {{4, 5}, {5, 4}, {4, 6}, {6, 4}, {5, 6}, {6, 5}, {4, 1}, {5, 2}, {6, 3}},
    {{0, 0}, {0, 0}, {0, 0}},
    30, 3, 100, 4,
    "branching"},
  {{{0, 1}, {0, 2}, {0, 3}} ->
      {{4, 5}, {5, 4}, {4, 6}, {6, 4}, {5, 6}, {6, 5}, {4, 1}, {5, 2}, {6, 3}, {1, 6}, {3, 4}},
    {{0, 1}, {0, 2}, {0, 3}},
    30, 3, 100, 4,
    "branching"},
  {{{0, 1}, {0, 2}, {0, 3}} ->
      {{4, 5}, {5, 4}, {4, 6}, {6, 4}, {5, 6}, {6, 5}, {4, 1}, {5, 2}, {6, 3}, {1, 6}, {3, 4}},
    {{0, 0}, {0, 0}, {0, 0}},
    30, 3, 100, 4,
    "branching"},
  {{{1, 2}, {1, 3}, {1, 4}} -> {{2, 3}, {2, 4}, {3, 3}, {3, 5}, {4, 5}},
    {{1, 1}, {1, 1}, {1, 1}},
    50, 7, 100, 9,
    "branching"},
  {{{1, 2, 3}, {4, 5, 6}, {1, 4}, {4, 1}} ->
      {{2, 7, 8}, {3, 9, 10}, {5, 11, 12}, {6, 13, 14}, {7, 11}, {8, 10}, {9, 13}, {10, 8}, {11, 7}, {12, 14},
        {13, 9}, {14, 12}},
    {{1, 2, 3}, {4, 5, 6}, {1, 4}, {2, 5}, {3, 6}, {4, 1}, {5, 2}, {6, 3}},
    8, 2, 100, 5,
    "branching"},
  {{{1, 2, 2}, {3, 4, 2}} -> {{2, 5, 5}, {5, 3, 2}, {5, 4, 6}, {7, 4, 5}},
    {{1, 1, 1}, {1, 1, 1}},
    30, 30, 1000, 1000,
    "sequential"},
  {{{1, 1, 2}} -> {{3, 2, 2}, {3, 3, 3}, {3, 3, 4}}, {{1, 1, 1}}, 100, 6, 2000, 10, "branching"},
  {{{{1, 2}, {1, 3}, {1, 4}} -> {{2, 3}, {3, 4}, {4, 5}, {5, 2}, {5, 4}}},
    {{1, 1}, {1, 1}, {1, 1}},
    40, 10, 100, 12,
    "branching"}};
