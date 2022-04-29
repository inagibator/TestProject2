object K_FormFileName: TK_FormFileName
  Left = 235
  Top = 103
  Width = 332
  Height = 87
  Caption = #1042#1099#1073#1086#1088' '#1080#1084#1077#1085#1080' '#1092#1072#1081#1083#1072
  Color = clBtnFace
  Constraints.MaxHeight = 87
  Constraints.MinHeight = 87
  Constraints.MinWidth = 150
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  DesignSize = (
    324
    53)
  PixelsPerInch = 96
  TextHeight = 13
  inline FileNameFrame: TN_FileNameFrame
    Tag = 161
    Left = 2
    Top = 1
    Width = 322
    Height = 25
    Anchors = [akLeft, akTop, akRight]
    PopupMenu = FileNameFrame.FilePopupMenu
    TabOrder = 0
    inherited Label1: TLabel
      Left = 56
      Width = 3
      Caption = ''
    end
    inherited mbFileName: TComboBox
      Left = 0
      Width = 292
    end
    inherited bnBrowse_1: TButton
      Left = 299
      Width = 19
    end
    inherited OpenDialog: TOpenDialog
      Filter = 
        'All files (*.*)|*.*| Binary files (*.sdb)|*.SDB|Text files (*.tx' +
        't;*.sdm)|*.TXT;*.SDM'
      Left = 88
    end
  end
  object BtCancel: TButton
    Left = 206
    Top = 30
    Width = 56
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = #1054#1090#1082#1072#1079
    ModalResult = 2
    TabOrder = 1
  end
  object BtOK: TButton
    Left = 267
    Top = 30
    Width = 56
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = #1054#1050
    ModalResult = 1
    TabOrder = 2
  end
end
