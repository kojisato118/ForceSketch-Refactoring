# ForceSketch-Refactoring
https://github.com/FlexMonkey/ForceSketch を自分なりに作り直してみたものです。
ただ、現状、iOS11では`imageAccumulator.setImage()`で落ちることを確認しています。
また、シミュレーターでしか確認していませんが、iOS10等では落ちずに動作はするが、本家READMEのgifの用に綺麗に動きません。

## やったこと
- swift2 -> swift4に直してビルドを通す
- タッチと描画を管理するのをViewControllerからカスタムViewに分離
