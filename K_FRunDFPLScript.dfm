inherited K_FormRunDFPLScript: TK_FormRunDFPLScript
  Left = 337
  Top = 259
  Width = 553
  Height = 334
  Caption = #1042#1099#1087#1086#1083#1085#1080#1090#1100' '#1085#1072#1073#1086#1088' '#1082#1086#1084#1072#1085#1076' DFPL'
  KeyPreview = True
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object LbPackDistr: TLabel [0]
    Left = 126
    Top = 259
    Width = 88
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = #1056#1077#1078#1080#1084' '#1091#1087#1072#1082#1086#1074#1082#1080':'
  end
  inherited BFMinBRPanel: TPanel
    Left = 533
    Top = 288
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 276
    Width = 537
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object GBScript: TGroupBox
    Left = 0
    Top = 32
    Width = 537
    Height = 43
    Align = alTop
    Caption = '  '#1053#1072#1073#1086#1088' '#1082#1086#1084#1072#1085#1076'  '
    TabOrder = 1
    DesignSize = (
      537
      43)
    object BtRun: TButton
      Left = 452
      Top = 14
      Width = 75
      Height = 21
      Action = RunDFPL
      Anchors = [akTop, akRight]
      Caption = #1042#1099#1087#1086#1083#1085#1080#1090#1100
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
    end
    object CmBScripts: TComboBox
      Left = 144
      Top = 15
      Width = 297
      Height = 21
      Style = csDropDownList
      Anchors = [akLeft, akTop, akRight]
      ItemHeight = 13
      TabOrder = 1
      OnChange = CmBScriptsChange
    end
    object BtSetParams: TButton
      Left = 9
      Top = 15
      Width = 128
      Height = 21
      Action = SetScriptParams
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 537
    Height = 32
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 2
    DesignSize = (
      537
      32)
    inline DFPLFileFrame: TN_FileNameFrame
      Tag = 161
      Left = 0
      Top = 0
      Width = 441
      Height = 25
      Anchors = [akLeft, akTop, akRight]
      PopupMenu = DFPLFileFrame.FilePopupMenu
      TabOrder = 0
      DesignSize = (
        441
        25)
      inherited Label1: TLabel
        Width = 91
        Caption = #1050#1086#1084#1072#1085#1076#1085#1099#1081' '#1092#1072#1081#1083':'
      end
      inherited mbFileName: TComboBox
        Left = 104
        Width = 309
      end
      inherited bnBrowse_1: TButton
        Left = 415
      end
      inherited OpenDialog: TOpenDialog
        Left = 141
      end
      inherited OpenPictureDialog: TOpenPictureDialog
        Left = 178
      end
      inherited FilePopupMenu: TPopupMenu
        Left = 209
      end
      inherited FNameActList: TActionList
        Left = 110
      end
    end
    object BtPrep: TButton
      Left = 452
      Top = 3
      Width = 75
      Height = 21
      Action = ReloadDFPLScripts
      Anchors = [akTop, akRight]
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
    end
  end
  object GBSrcContext: TGroupBox
    Left = 0
    Top = 75
    Width = 537
    Height = 72
    Align = alTop
    Caption = '  '#1048#1089#1093#1086#1076#1085#1099#1081' '#1082#1086#1085#1090#1077#1082#1089#1090'  '
    TabOrder = 3
    inline SrcPathNameFrame: TK_FPathNameFrame
      Tag = 161
      Left = 2
      Top = 43
      Width = 533
      Height = 27
      Align = alBottom
      TabOrder = 0
      DesignSize = (
        533
        27)
      inherited LbPathName: TLabel
        Left = 5
        Width = 82
        Caption = #1048#1089#1093#1086#1076#1085#1099#1081' '#1087#1091#1090#1100' :'
      end
      inherited mbPathName: TComboBox
        Left = 95
        Width = 402
      end
      inherited bnBrowse_1: TButton
        Left = 507
        Top = 2
      end
    end
    inline SrcIniFileFrame: TN_FileNameFrame
      Tag = 161
      Left = 2
      Top = 15
      Width = 533
      Height = 25
      Align = alTop
      PopupMenu = DFPLFileFrame.FilePopupMenu
      TabOrder = 1
      DesignSize = (
        533
        25)
      inherited Label1: TLabel
        Width = 97
        Caption = #1048#1089#1093#1086#1076#1085#1099#1081' Ini-'#1092#1072#1081#1083':'
      end
      inherited mbFileName: TComboBox
        Left = 111
        Width = 386
      end
      inherited bnBrowse_1: TButton
        Left = 507
      end
      inherited OpenDialog: TOpenDialog
        Left = 141
      end
      inherited OpenPictureDialog: TOpenPictureDialog
        Left = 178
      end
      inherited FilePopupMenu: TPopupMenu
        Left = 209
      end
      inherited FNameActList: TActionList
        Left = 110
      end
    end
  end
  object CmBPackDist: TComboBox
    Left = 224
    Top = 256
    Width = 73
    Height = 21
    Anchors = [akLeft, akBottom]
    ItemHeight = 13
    ItemIndex = 0
    TabOrder = 5
    Text = 'None'
    Items.Strings = (
      'None'
      'ZIP'
      'RAR')
  end
  object GBDstContext: TGroupBox
    Left = 0
    Top = 147
    Width = 537
    Height = 105
    Align = alTop
    Caption = '  '#1056#1077#1079#1091#1083#1100#1090#1080#1088#1091#1102#1097#1080#1081' '#1082#1086#1085#1090#1077#1082#1089#1090'  '
    TabOrder = 6
    object GBIniParams: TGroupBox
      Left = 2
      Top = 15
      Width = 533
      Height = 58
      Align = alTop
      Caption = '  '#1056#1077#1079#1091#1083#1100#1090#1080#1088#1091#1102#1097#1080#1081' Ini-'#1092#1072#1081#1083'  '
      TabOrder = 0
      DesignSize = (
        533
        58)
      object Label1: TLabel
        Left = 162
        Top = 20
        Width = 28
        Height = 13
        Caption = #1048#1084#1103' :'
      end
      object ChBEncriptIni: TCheckBox
        Left = 8
        Top = 16
        Width = 133
        Height = 17
        Caption = #1089#1082#1088#1099#1090#1100' '#1089#1086#1076#1077#1088#1078#1080#1084#1086#1077
        TabOrder = 0
      end
      object ChBSkipSaveIni: TCheckBox
        Left = 8
        Top = 35
        Width = 141
        Height = 17
        Caption = #1079#1072#1087#1088#1077#1090#1080#1090#1100' '#1089#1086#1093#1088#1072#1085#1077#1085#1080#1077
        TabOrder = 1
      end
      object EdIniName: TEdit
        Left = 195
        Top = 16
        Width = 335
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 2
      end
    end
    inline DstPathNameFrame: TK_FPathNameFrame
      Tag = 161
      Left = 2
      Top = 73
      Width = 533
      Height = 27
      Align = alTop
      TabOrder = 1
      DesignSize = (
        533
        27)
      inherited LbPathName: TLabel
        Left = 6
        Width = 118
        Caption = #1056#1077#1079#1091#1083#1100#1090#1080#1088#1091#1102#1097#1080#1081' '#1087#1091#1090#1100' :'
      end
      inherited mbPathName: TComboBox
        Left = 128
        Width = 369
      end
      inherited bnBrowse_1: TButton
        Left = 508
      end
    end
  end
  object ActionList1: TActionList
    Left = 16
    Top = 104
    object RunDFPL: TAction
      Caption = #1042#1099#1087#1086#1083#1085#1080#1090#1100' '#1082#1086#1084#1072#1085#1076#1099' '
      Hint = #1042#1099#1087#1086#1083#1085#1080#1090#1100' '#1085#1072#1073#1086#1088' '#1082#1086#1084#1072#1085#1076'  '
      OnExecute = RunDFPLExecute
    end
    object ReloadDFPLScripts: TAction
      Caption = #1054#1073#1085#1086#1074#1080#1090#1100
      Hint = #1054#1073#1085#1086#1074#1080#1090#1100' '#1089#1086#1076#1077#1088#1078#1080#1084#1086#1077' '#1085#1072#1073#1086#1088#1086#1074' '#1082#1086#1084#1072#1085#1076' '#1080' '#1087#1072#1088#1072#1084#1077#1090#1088#1086#1074
      OnExecute = ReloadDFPLScriptsExecute
    end
    object SetScriptParams: TAction
      Caption = #1048#1079#1084#1077#1085#1080#1090#1100
      Hint = #1048#1079#1084#1077#1085#1080#1090#1100' '#1087#1072#1088#1072#1084#1077#1090#1088#1099' '#1085#1072#1073#1086#1088#1072' '#1082#1086#1084#1072#1085#1076
      OnExecute = SetScriptParamsExecute
    end
  end
end
