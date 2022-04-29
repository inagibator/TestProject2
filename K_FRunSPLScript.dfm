inherited K_FormRunSPLScript: TK_FormRunSPLScript
  Left = 470
  Top = 273
  Width = 376
  Height = 104
  Caption = #1042#1099#1087#1086#1083#1085#1080#1090#1100
  Constraints.MaxHeight = 104
  Constraints.MinHeight = 104
  OldCreateOrder = True
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object LbFunc: TLabel [0]
    Left = 9
    Top = 33
    Width = 58
    Height = 13
    Caption = #1055#1088#1086#1094#1077#1076#1091#1088#1072':'
  end
  inherited BFMinBRPanel: TPanel
    Left = 356
    Top = 58
    TabOrder = 4
  end
  inline SPLFileFrame: TN_FileNameFrame
    Tag = 161
    Left = 0
    Top = 2
    Width = 369
    Height = 32
    Anchors = [akLeft, akTop, akRight]
    PopupMenu = SPLFileFrame.FilePopupMenu
    TabOrder = 0
    inherited Label1: TLabel
      Left = 8
      Width = 91
      Caption = #1050#1086#1084#1072#1085#1076#1085#1099#1081' '#1092#1072#1081#1083':'
    end
    inherited mbFileName: TComboBox
      Left = 104
      Width = 233
    end
    inherited bnBrowse_1: TButton
      Left = 342
      Width = 22
    end
    inherited OpenDialog: TOpenDialog
      Filter = 'Program Files( *.spl )|*.spl|All files (*.*)|*.*'
      Left = 168
    end
  end
  object CmBFunc: TComboBox
    Left = 112
    Top = 29
    Width = 168
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 13
    TabOrder = 1
  end
  object BtPrep: TButton
    Left = 13
    Top = 53
    Width = 101
    Height = 21
    Action = PrepUnit
    TabOrder = 2
    Visible = False
  end
  object BtRun: TButton
    Left = 288
    Top = 29
    Width = 76
    Height = 21
    Action = RunSPL
    Anchors = [akTop, akRight]
    TabOrder = 3
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 51
    Width = 368
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object ActionList1: TActionList
    object RunSPL: TAction
      Caption = #1042#1099#1087#1086#1083#1085#1080#1090#1100
      OnExecute = RunSPLExecute
    end
    object PrepUnit: TAction
      Caption = #1055#1086#1076#1075#1086#1090#1086#1074#1080#1090#1100
      OnExecute = PrepUnitExecute
    end
  end
end
