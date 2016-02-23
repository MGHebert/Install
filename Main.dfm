object fmMain: TfmMain
  Left = 564
  Top = 363
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  ClientHeight = 71
  ClientWidth = 412
  Color = 10538959
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object sbMain: TTntStatusBar
    Left = 0
    Top = 52
    Width = 412
    Height = 19
    Color = 10538959
    Panels = <>
    ParentFont = True
    UseSystemFont = False
  end
  object TntGroupBox1: TTntGroupBox
    Left = 0
    Top = 0
    Width = 412
    Height = 52
    Align = alClient
    Caption = 'Configuring Netstop Pro...'
    TabOrder = 1
    object pbMain: TTntProgressBar
      Left = 8
      Top = 24
      Width = 393
      Height = 16
      TabOrder = 0
    end
  end
  object tmMain: TTimer
    OnTimer = tmMainTimer
    Left = 312
    Top = 8
  end
end
