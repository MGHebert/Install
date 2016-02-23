object fmUserType: TfmUserType
  Left = 545
  Top = 376
  BorderIcons = []
  BorderStyle = bsSingle
  Caption = 'Select User Type'
  ClientHeight = 122
  ClientWidth = 230
  Color = 10538959
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object RadioGroupUserType: TTntRadioGroup
    Left = 0
    Top = 0
    Width = 229
    Height = 45
    Caption = 'User Type'
    Columns = 2
    ItemIndex = 0
    Items.Strings = (
      'Local User'
      'Domain User')
    TabOrder = 0
    OnClick = RadioGroupUserTypeClick
  end
  object btnOK: TIBEAntialiasButton
    Left = 129
    Top = 91
    Width = 96
    Height = 30
    Cursor = crHandPoint
    Caption = 'OK'
    TabOrder = 1
    TabStop = False
    OnClick = btnOKClick
    BackColor = 16764057
    CaptionAlignment = taLeftJustify
    CornerRound = 5
    GlyphSeparation = 5
    Properties.Disabled.Border = clSilver
    Properties.Disabled.Color = clBlue
    Properties.Disabled.Font.Charset = DEFAULT_CHARSET
    Properties.Disabled.Font.Color = clSilver
    Properties.Disabled.Font.Height = -11
    Properties.Disabled.Font.Name = 'MS Sans Serif'
    Properties.Disabled.Font.Style = [fsBold]
    Properties.FocusColor = clWhite
    Properties.MouseAway.Border = clWhite
    Properties.MouseAway.Color = clBlue
    Properties.MouseAway.Font.Charset = DEFAULT_CHARSET
    Properties.MouseAway.Font.Color = clWhite
    Properties.MouseAway.Font.Height = -11
    Properties.MouseAway.Font.Name = 'MS Sans Serif'
    Properties.MouseAway.Font.Style = [fsBold]
    Properties.MouseDown.Border = clWhite
    Properties.MouseDown.Color = 16750848
    Properties.MouseDown.Font.Charset = DEFAULT_CHARSET
    Properties.MouseDown.Font.Color = clWhite
    Properties.MouseDown.Font.Height = -11
    Properties.MouseDown.Font.Name = 'MS Sans Serif'
    Properties.MouseDown.Font.Style = [fsBold]
    Properties.MouseOver.Border = clNavy
    Properties.MouseOver.Color = clBlue
    Properties.MouseOver.Font.Charset = DEFAULT_CHARSET
    Properties.MouseOver.Font.Color = 8454143
    Properties.MouseOver.Font.Height = -11
    Properties.MouseOver.Font.Name = 'MS Sans Serif'
    Properties.MouseOver.Font.Style = [fsBold]
    ShowFocus = False
  end
  object GroupBoxDomainName: TTntGroupBox
    Left = 0
    Top = 48
    Width = 229
    Height = 41
    Caption = 'Domain Nme'
    TabOrder = 2
    object ebDomain: TTntEdit
      Left = 4
      Top = 16
      Width = 221
      Height = 21
      Enabled = False
      TabOrder = 0
    end
  end
end
