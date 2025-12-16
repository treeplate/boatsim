{ pkgs, legacyPolygott }: {
    deps = [
        pkgs.replitPackages.dart2_10
    ] ++ legacyPolygott;
}