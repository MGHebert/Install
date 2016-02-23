object fmUserSelect: TfmUserSelect
  Left = 448
  Top = 203
  Width = 536
  Height = 563
  Caption = 'fmUserSelect'
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
  object pnMain: TTntPanel
    Left = 0
    Top = 0
    Width = 528
    Height = 500
    Align = alClient
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 0
    object gbUsers: TTntGroupBox
      Left = 0
      Top = 0
      Width = 528
      Height = 500
      Align = alClient
      Caption = 'gbUsers'
      TabOrder = 0
      object pnDomain: TTntPanel
        Left = 2
        Top = 15
        Width = 524
        Height = 46
        Align = alTop
        BevelOuter = bvNone
        ParentColor = True
        TabOrder = 0
        object LabelDomain: TTntLabel
          Left = 4
          Top = 4
          Width = 62
          Height = 13
          Caption = 'LabelDomain'
        end
        object LabelMemberOf: TTntLabel
          Left = 276
          Top = 32
          Width = 75
          Height = 13
          Caption = 'LabelMemberOf'
        end
        object ebDomain: TTntEdit
          Left = 4
          Top = 20
          Width = 169
          Height = 21
          TabOrder = 0
        end
      end
      object btnList: TIBEAntialiasButton
        Left = 180
        Top = 26
        Width = 73
        Height = 30
        Cursor = crHandPoint
        Caption = 'btnList'
        TabOrder = 1
        OnClick = btnListClick
        BackColor = 16750848
        CaptionAlignment = taLeftJustify
        CornerRound = 7
        GlyphSeparation = 5
        Margins.Left = 5
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
        Properties.MouseDown.Font.Name = 'Default'
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
      object tvUsers: TTntTreeView
        Left = 6
        Top = 60
        Width = 267
        Height = 437
        Indent = 19
        TabOrder = 2
        OnChange = tvUsersChange
      end
      object ListBoxGroups: TTntListBox
        Left = 272
        Top = 60
        Width = 245
        Height = 437
        ItemHeight = 13
        TabOrder = 3
      end
    end
  end
  object pnBottom: TTntPanel
    Left = 0
    Top = 500
    Width = 528
    Height = 36
    Align = alBottom
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 1
    object pnApply: TTntPanel
      Left = 320
      Top = 0
      Width = 208
      Height = 36
      Align = alRight
      BevelOuter = bvNone
      ParentColor = True
      TabOrder = 0
      object btnOK: TIBEAntialiasButton
        Left = 5
        Top = 2
        Width = 96
        Height = 30
        Cursor = crHandPoint
        Caption = 'btnOK'
        TabOrder = 0
        OnClick = btnOKClick
        BackColor = 16750848
        CaptionAlignment = taLeftJustify
        CornerRound = 7
        GlyphSeparation = 5
        Margins.Left = 5
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
        Properties.MouseDown.Font.Name = 'Default'
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
      object btnCancel: TIBEAntialiasButton
        Left = 105
        Top = 2
        Width = 96
        Height = 30
        Cursor = crHandPoint
        Caption = 'btnCancel'
        TabOrder = 1
        OnClick = btnCancelClick
        BackColor = 16750848
        CaptionAlignment = taLeftJustify
        CornerRound = 7
        GlyphSeparation = 5
        Margins.Left = 5
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
        Properties.MouseDown.Font.Name = 'Default'
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
    end
    object pnNew: TTntPanel
      Left = 0
      Top = 0
      Width = 320
      Height = 36
      Align = alClient
      BevelOuter = bvNone
      ParentColor = True
      TabOrder = 1
    end
  end
end
