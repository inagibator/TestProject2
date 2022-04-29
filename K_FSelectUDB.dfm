inherited K_FormSelectUDB: TK_FormSelectUDB
  Left = 327
  Top = 223
  Width = 402
  Height = 374
  Caption = 'K_FormSelectUDB'
  Position = poDefaultPosOnly
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 382
    Top = 328
    TabOrder = 4
  end
  object PnSaveAs: TPanel
    Left = 0
    Top = 280
    Width = 386
    Height = 28
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    DesignSize = (
      386
      28)
    object LbObjName: TLabel
      Left = 10
      Top = 12
      Width = 73
      Height = 13
      Caption = #1048#1084#1103' '#1086#1073#1098#1077#1082#1090#1072' :'
    end
    object LbObjType: TLabel
      Left = 10
      Top = 43
      Width = 70
      Height = 13
      Caption = #1058#1080#1087' '#1086#1073#1098#1077#1082#1090#1072' :'
    end
    object BtOK1: TButton
      Left = 331
      Top = 8
      Width = 54
      Height = 21
      Caption = 'OK'
      ModalResult = 1
      TabOrder = 0
    end
    object BtCansel1: TButton
      Left = 331
      Top = 40
      Width = 59
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Caption = #1054#1090#1082#1072#1079
      ModalResult = 2
      TabOrder = 1
      Visible = False
    end
    object EdObjName: TEdit
      Left = 86
      Top = 8
      Width = 243
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 2
    end
    object CmBObjType: TComboBox
      Left = 86
      Top = 40
      Width = 244
      Height = 21
      Style = csDropDownList
      Anchors = [akLeft, akTop, akRight]
      ItemHeight = 13
      TabOrder = 3
    end
  end
  inline VTreeFrame: TN_VTreeFrame
    Left = 0
    Top = 28
    Width = 386
    Height = 252
    Align = alClient
    Color = clWhite
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsItalic]
    ParentColor = False
    ParentFont = False
    TabOrder = 0
    inherited TreeView: TTreeView
      Width = 386
      Height = 252
    end
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 386
    Height = 28
    ButtonHeight = 24
    ButtonWidth = 25
    Caption = 'ToolBar1'
    Images = N_ButtonsForm.ButtonsList
    TabOrder = 3
    object ToolButton1: TToolButton
      Left = 0
      Top = 2
      Action = VTreeFrame.StepUp
    end
    object ToolButton2: TToolButton
      Left = 25
      Top = 2
      Action = VTreeFrame.StepDown
    end
  end
  object PnSelect: TPanel
    Left = 0
    Top = 308
    Width = 386
    Height = 27
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      386
      27)
    object BtOK: TButton
      Left = 344
      Top = 4
      Width = 50
      Height = 21
      Anchors = [akTop, akRight]
      Caption = 'OK'
      ModalResult = 1
      TabOrder = 0
    end
    object BtCancel: TButton
      Left = 288
      Top = 4
      Width = 50
      Height = 21
      Anchors = [akTop, akRight]
      Caption = #1054#1090#1082#1072#1079
      ModalResult = 2
      TabOrder = 1
    end
  end
end
