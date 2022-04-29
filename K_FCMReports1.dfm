inherited K_FormCMReports1: TK_FormCMReports1
  Left = 370
  Top = 211
  BorderStyle = bsDialog
  Caption = 'Reports'
  ClientHeight = 521
  ClientWidth = 340
  OldCreateOrder = True
  OnShow = FormShow
  ExplicitWidth = 346
  ExplicitHeight = 550
  PixelsPerInch = 96
  TextHeight = 13
  object LbProviders: TLabel [0]
    Left = 16
    Top = 412
    Width = 67
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'Staff members'
    ExplicitTop = 393
  end
  object LbLocations: TLabel [1]
    Left = 16
    Top = 452
    Width = 46
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'Locations'
    ExplicitTop = 433
  end
  inherited BFMinBRPanel: TPanel
    Left = 330
    Top = 511
    TabOrder = 8
    ExplicitLeft = 330
    ExplicitTop = 511
  end
  object GBDates: TGroupBox
    Left = 16
    Top = 8
    Width = 153
    Height = 105
    Caption = '  Dates  '
    TabOrder = 0
    object LbFrom: TLabel
      Left = 13
      Top = 32
      Width = 23
      Height = 13
      Caption = 'From'
    end
    object LbTo: TLabel
      Left = 21
      Top = 64
      Width = 13
      Height = 13
      Caption = 'To'
    end
    object DTPFrom: TDateTimePicker
      Left = 45
      Top = 28
      Width = 95
      Height = 21
      Date = 39542.430481226850000000
      Format = 'dd/MM/yyyy'
      Time = 39542.430481226850000000
      Color = 10682367
      TabOrder = 0
    end
    object DTPTo: TDateTimePicker
      Left = 45
      Top = 60
      Width = 95
      Height = 21
      Date = 39542.430481226850000000
      Format = 'dd/MM/yyyy'
      Time = 39542.430481226850000000
      Color = 10682367
      TabOrder = 1
    end
  end
  object GBActions: TGroupBox
    Left = 184
    Top = 8
    Width = 137
    Height = 209
    Caption = '  Actions  '
    TabOrder = 1
    object ChBAllActs: TCheckBox
      Left = 16
      Top = 16
      Width = 114
      Height = 17
      Caption = 'All'
      TabOrder = 0
      OnClick = ChBAllActsClick
    end
    object ChBObjCreate: TCheckBox
      Left = 16
      Top = 40
      Width = 114
      Height = 17
      Caption = 'Create new object'
      TabOrder = 1
    end
    object ChBModify: TCheckBox
      Left = 16
      Top = 64
      Width = 114
      Height = 17
      Caption = 'Modify'
      TabOrder = 2
    end
    object ChBDelete: TCheckBox
      Left = 16
      Top = 88
      Width = 114
      Height = 17
      Caption = 'Delete'
      TabOrder = 3
    end
    object ChBExport: TCheckBox
      Left = 16
      Top = 112
      Width = 114
      Height = 17
      Caption = 'Export'
      TabOrder = 4
    end
    object ChBPrint: TCheckBox
      Left = 16
      Top = 136
      Width = 114
      Height = 17
      Caption = 'Print'
      TabOrder = 5
    end
    object ChBEmail: TCheckBox
      Left = 16
      Top = 160
      Width = 114
      Height = 17
      Caption = 'Email'
      TabOrder = 6
    end
    object ChBArchRest: TCheckBox
      Left = 16
      Top = 184
      Width = 114
      Height = 17
      Caption = 'Archive / Restore'
      TabOrder = 7
    end
  end
  object ChBCurPat: TCheckBox
    Left = 34
    Top = 136
    Width = 121
    Height = 17
    Caption = 'Current patient'
    TabOrder = 2
  end
  object CmBProviders: TComboBox
    Left = 96
    Top = 408
    Width = 225
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akBottom]
    Color = 10682367
    TabOrder = 3
  end
  object CmBLocations: TComboBox
    Left = 96
    Top = 448
    Width = 225
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akBottom]
    Color = 10682367
    TabOrder = 4
  end
  object LbEdSlideID: TLabeledEdit
    Left = 34
    Top = 168
    Width = 65
    Height = 21
    Color = 10682367
    EditLabel.Width = 60
    EditLabel.Height = 13
    EditLabel.Caption = '  Object ID   '
    LabelPosition = lpRight
    TabOrder = 5
  end
  object BtRun: TButton
    Left = 16
    Top = 488
    Width = 75
    Height = 23
    Anchors = [akLeft, akBottom]
    Caption = 'Run'
    TabOrder = 6
    OnClick = BtRunClick
  end
  object BtExit: TButton
    Left = 248
    Top = 488
    Width = 75
    Height = 23
    Anchors = [akLeft, akBottom]
    Caption = 'Exit'
    ModalResult = 2
    TabOrder = 7
  end
  object GBSActions: TGroupBox
    Left = 16
    Top = 224
    Width = 305
    Height = 169
    Caption = '  Special Actions  '
    TabOrder = 9
    object ChBImportAC: TCheckBox
      Left = 16
      Top = 24
      Width = 257
      Height = 17
      Caption = 'Import after imaging system conversion'
      TabOrder = 0
    end
    object ChBUndoImportAC: TCheckBox
      Left = 16
      Top = 48
      Width = 257
      Height = 17
      Caption = 'Undo import after imaging system conversion'
      TabOrder = 1
    end
    object ChBCMSSettings: TCheckBox
      Left = 16
      Top = 72
      Width = 257
      Height = 17
      Caption = 'Media Suite settings change'
      TabOrder = 2
    end
    object ChBCaptureDevice: TCheckBox
      Left = 16
      Top = 96
      Width = 257
      Height = 17
      Caption = 'Media Suite Capture Device setup'
      TabOrder = 3
    end
    object ChBAdvancedFilter: TCheckBox
      Left = 16
      Top = 119
      Width = 257
      Height = 17
      Caption = 'Advanced Image Filter setup'
      TabOrder = 4
    end
    object cbRadiologyLog: TCheckBox
      Left = 16
      Top = 142
      Width = 257
      Height = 17
      Caption = 'Radiology log'
      TabOrder = 5
      OnClick = cbRadiologyLogClick
    end
  end
end
