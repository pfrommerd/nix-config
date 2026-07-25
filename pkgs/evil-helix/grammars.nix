{
  lib,
  runCommand,
  source,
  stdenv,
}:

let
  languagesConfig = builtins.fromTOML (builtins.readFile "${source}/languages.toml");

  isGitGrammar =
    grammar:
    grammar ? source
    && grammar.source ? git
    && grammar.source ? rev;

  isGitHubGrammar = grammar: lib.hasPrefix "https://github.com" grammar.source.git;

  toGitHubFetcher =
    url:
    let
      match = builtins.match "https://github\\.com/([^/]*)/([^/]*)/?" url;
    in
    {
      owner = builtins.elemAt match 0;
      repo = builtins.elemAt match 1;
    };

  useGrammar =
    grammar:
    if languagesConfig ? use-grammars.only then
      builtins.elem grammar.name languagesConfig.use-grammars.only
    else if languagesConfig ? use-grammars.except then
      !(builtins.elem grammar.name languagesConfig.use-grammars.except)
    else
      true;

  buildGrammar =
    grammar:
    let
      github = toGitHubFetcher grammar.source.git;
      gitSource = builtins.fetchTree {
        type = "git";
        url = grammar.source.git;
        rev = grammar.source.rev;
        ref = grammar.source.ref or "HEAD";
        shallow = true;
      };
      githubSource = builtins.fetchTree {
        type = "github";
        inherit (github) owner repo;
        inherit (grammar.source) rev;
      };
      grammarSource = if isGitHubGrammar grammar then githubSource else gitSource;
    in
    stdenv.mkDerivation {
      pname = "evil-helix-tree-sitter-${grammar.name}";
      version = grammar.source.rev;

      src = grammarSource;
      sourceRoot =
        if grammar.source ? subpath then
          "source/${grammar.source.subpath}"
        else
          "source";

      dontConfigure = true;

      FLAGS = [
        "-Isrc"
        "-g"
        "-O3"
        "-fPIC"
        "-fno-exceptions"
        "-Wl,-z,relro,-z,now"
      ];

      grammarLibrary = grammar.name + stdenv.hostPlatform.extensions.sharedLibrary;

      buildPhase = ''
        runHook preBuild

        if [[ -e src/scanner.cc ]]; then
          $CXX -c src/scanner.cc -o scanner.o $FLAGS
        elif [[ -e src/scanner.c ]]; then
          $CC -c src/scanner.c -o scanner.o $FLAGS
        fi

        $CC -c src/parser.c -o parser.o $FLAGS
        $CXX -shared -o $grammarLibrary *.o

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        mkdir -p $out
        mv $grammarLibrary $out/

        runHook postInstall
      '';

      fixupPhase = lib.optionalString stdenv.hostPlatform.isLinux ''
        runHook preFixup
        $STRIP $out/$grammarLibrary
        runHook postFixup
      '';
    };

  grammarsToBuild = builtins.filter isGitGrammar (
    builtins.filter useGrammar languagesConfig.grammar
  );

  grammarLinks = map (
    grammar:
    let
      artifact = buildGrammar grammar;
      library = grammar.name + stdenv.hostPlatform.extensions.sharedLibrary;
    in
    "ln -s ${artifact}/${library} $out/${library}"
  ) grammarsToBuild;
in
runCommand "evil-helix-grammars" { } ''
  mkdir -p $out
  ${builtins.concatStringsSep "\n" grammarLinks}
''
