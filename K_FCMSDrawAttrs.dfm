inherited K_FormCMSDrawAttrs: TK_FormCMSDrawAttrs
  Left = 282
  Top = 591
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Format Annotations'
  ClientHeight = 86
  ClientWidth = 342
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object LbUnit: TLabel [0]
    Left = 150
    Top = 20
    Width = 54
    Height = 13
    Caption = 'Line Width:'
  end
  object LbColor: TLabel [1]
    Left = 13
    Top = 20
    Width = 27
    Height = 13
    Caption = 'Color:'
  end
  inherited BFMinBRPanel: TPanel
    Left = 332
    Top = 76
    TabOrder = 6
  end
  object BtCancel: TButton
    Left = 251
    Top = 55
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 0
  end
  object BtOK: TButton
    Left = 169
    Top = 55
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    ModalResult = 1
    TabOrder = 1
  end
  object CmBLineWidth: TComboBox
    Left = 209
    Top = 16
    Width = 122
    Height = 25
    Style = csOwnerDrawVariable
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 19
    ItemIndex = 0
    TabOrder = 2
    Text = ' very thin'
    OnChange = CmBLineWidthChange
    OnDrawItem = CmBLineWidthDrawItem
    OnKeyDown = LbEColorKeyDown
    Items.Strings = (
      ' very thin'
      ' thin '
      ' middle'
      ' thick'
      ' very thick')
  end
  object ColorBox: TColorBox
    Left = 44
    Top = 16
    Width = 88
    Height = 22
    Style = [cbStandardColors, cbPrettyNames]
    ItemHeight = 16
    TabOrder = 3
    Visible = False
    OnChange = CmBLineWidthChange
    OnKeyDown = LbEColorKeyDown
  end
  object BtFont: TButton
    Left = 34
    Top = 55
    Width = 98
    Height = 23
    Hint = 'Click to edit font attributes'
    Anchors = [akRight, akBottom]
    Caption = 'Font Attributes'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 4
    Visible = False
    OnClick = BtFontClick
  end
  object PnColor: TPanel
    Left = 45
    Top = 13
    Width = 86
    Height = 28
    Anchors = [akLeft, akTop, akRight]
    BevelWidth = 2
    BorderWidth = 2
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentBackground = False
    ParentFont = False
    TabOrder = 5
    OnClick = PnColorClick
  end
  object ChBMLineDisplay: TCheckBox
    Left = 11
    Top = 59
    Width = 154
    Height = 17
    Caption = 'Display length of segments'
    TabOrder = 7
    OnClick = ChBMLineDisplayClick
  end
end
