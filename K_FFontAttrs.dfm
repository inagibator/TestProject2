inherited K_FormFontAttrs: TK_FormFontAttrs
  Left = 245
  Top = 257
  BorderStyle = bsSingle
  Caption = '_Font attributes'
  ClientHeight = 208
  ClientWidth = 252
  PixelsPerInch = 96
  TextHeight = 13
  object LbFonts: TLabel [0]
    Left = 8
    Top = 13
    Width = 48
    Height = 13
    Caption = 'Font face:'
  end
  object LbFontStyle: TLabel [1]
    Left = 72
    Top = 66
    Width = 48
    Height = 13
    Caption = 'Font style:'
  end
  object SBtBold: TSpeedButton [2]
    Tag = 1
    Left = 69
    Top = 80
    Width = 25
    Height = 25
    GroupIndex = 1
    Caption = 'B'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    OnClick = SBtBoldClick
  end
  object SBtItalic: TSpeedButton [3]
    Tag = 2
    Left = 96
    Top = 80
    Width = 25
    Height = 25
    GroupIndex = 2
    Caption = 'I'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Verdana'
    Font.Style = [fsBold, fsItalic]
    ParentFont = False
    OnClick = SBtBoldClick
  end
  object SbtULine: TSpeedButton [4]
    Tag = 3
    Left = 123
    Top = 80
    Width = 25
    Height = 25
    GroupIndex = 3
    Caption = 'U'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold, fsUnderline]
    ParentFont = False
    OnClick = SBtBoldClick
  end
  object SBtSLine: TSpeedButton [5]
    Tag = 4
    Left = 150
    Top = 80
    Width = 25
    Height = 25
    GroupIndex = 4
    Caption = 'S'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold, fsStrikeOut]
    ParentFont = False
    OnClick = SBtBoldClick
  end
  object LbTextColor: TLabel [6]
    Left = 192
    Top = 65
    Width = 50
    Height = 13
    Caption = 'Text color:'
  end
  inherited BFMinBRPanel: TPanel
    Left = 242
    Top = 198
    TabOrder = 7
  end
  object CmBFontFace: TComboBox
    Left = 8
    Top = 29
    Width = 236
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 13
    TabOrder = 0
    OnChange = CmBFontFaceChange
  end
  object BtCancel: TButton
    Left = 169
    Top = 174
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object BtOK: TButton
    Left = 81
    Top = 174
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 2
  end
  object UDFontSize: TUpDown
    Left = 36
    Top = 82
    Width = 16
    Height = 21
    Associate = EdFontSize
    Min = 5
    Max = 1000
    Position = 5
    TabOrder = 3
    OnClick = UDFontSizeClick
    OnEnter = UDFontSizeEnter
  end
  object EdFontSize: TLabeledEdit
    Left = 7
    Top = 82
    Width = 29
    Height = 21
    EditLabel.Width = 45
    EditLabel.Height = 13
    EditLabel.Caption = 'Font size:'
    EditLabel.Font.Charset = DEFAULT_CHARSET
    EditLabel.Font.Color = clWindowText
    EditLabel.Font.Height = -11
    EditLabel.Font.Name = 'MS Sans Serif'
    EditLabel.Font.Style = []
    EditLabel.ParentFont = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 4
    Text = '5'
    OnKeyDown = EdFontSizeKeyDown
  end
  object PnColor: TPanel
    Left = 192
    Top = 79
    Width = 51
    Height = 28
    Anchors = [akLeft, akTop, akRight]
    BevelWidth = 2
    BorderWidth = 2
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 5
    OnClick = PnColorClick
  end
  object GBSample: TGroupBox
    Left = 8
    Top = 119
    Width = 236
    Height = 40
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = '  Sample  '
    TabOrder = 6
    DesignSize = (
      236
      40)
    object MemoSample: TMemo
      Left = 8
      Top = 16
      Width = 217
      Height = 15
      Anchors = [akLeft, akTop, akRight, akBottom]
      ReadOnly = True
      TabOrder = 0
      WordWrap = False
    end
  end
end
