inherited K_FormCMSUDefFilters1: TK_FormCMSUDefFilters1
  Left = 419
  Top = 63
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'User defined media filter'
  ClientHeight = 558
  ClientWidth = 640
  OldCreateOrder = True
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 630
    Top = 548
    TabOrder = 4
  end
  object GbMediaTypes: TGroupBox
    Left = 360
    Top = 90
    Width = 272
    Height = 46
    Anchors = [akTop, akRight]
    Caption = '  Media Category  '
    TabOrder = 0
    DesignSize = (
      272
      46)
    object CmBMediaTypes: TComboBox
      Left = 9
      Top = 15
      Width = 254
      Height = 21
      Style = csDropDownList
      Anchors = [akLeft, akTop, akRight]
      Color = 10682367
      ItemHeight = 13
      TabOrder = 0
    end
  end
  object GbToothAlloc: TGroupBox
    Left = 8
    Top = 138
    Width = 625
    Height = 376
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = '  Tooth Allocations  '
    TabOrder = 1
    DesignSize = (
      625
      376)
    object BtResetChart: TButton
      Left = 492
      Top = 338
      Width = 123
      Height = 25
      Action = aResetChart
      Anchors = [akRight, akBottom]
      TabOrder = 0
    end
    inline CMSTeethChartFrame: TK_FrameCMTeethChart1
      Left = 13
      Top = 22
      Width = 600
      Height = 300
      TabOrder = 1
    end
  end
  object Button2: TButton
    Left = 481
    Top = 525
    Width = 65
    Height = 25
    Action = aCLoseOK
    Anchors = [akRight, akBottom]
    TabOrder = 2
  end
  object Button1: TButton
    Left = 558
    Top = 525
    Width = 65
    Height = 25
    Action = aCloseCancel
    Anchors = [akRight, akBottom]
    TabOrder = 3
  end
  object GBUDFProfiles: TGroupBox
    Left = 360
    Top = 4
    Width = 272
    Height = 81
    Anchors = [akTop, akRight]
    Caption = '  Filter profile name  '
    TabOrder = 5
    object CmBUDPNames: TComboBox
      Left = 9
      Top = 15
      Width = 254
      Height = 21
      Color = 10682367
      ItemHeight = 13
      TabOrder = 0
      OnKeyPress = CmBUDPNamesKeyPress
      OnSelect = CmBUDPNamesSelect
    end
    object BtAdd: TButton
      Left = 8
      Top = 48
      Width = 80
      Height = 23
      Action = aAdd
      TabOrder = 1
    end
    object BtMod: TButton
      Left = 95
      Top = 48
      Width = 80
      Height = 23
      Action = aSave
      TabOrder = 2
    end
    object BtDel: TButton
      Left = 182
      Top = 48
      Width = 80
      Height = 23
      Action = aDelete
      TabOrder = 3
    end
  end
  object GBDates: TGroupBox
    Left = 8
    Top = 6
    Width = 337
    Height = 130
    Caption = '  Dates  '
    TabOrder = 6
    object LbFrom: TLabel
      Left = 208
      Top = 52
      Width = 23
      Height = 13
      Caption = 'From'
    end
    object LbTo: TLabel
      Left = 210
      Top = 92
      Width = 13
      Height = 13
      Caption = 'To'
    end
    object RBDateAll: TRadioButton
      Left = 32
      Top = 16
      Width = 81
      Height = 17
      Caption = 'All'
      TabOrder = 0
      OnClick = RBDateAllClick
    end
    object RBDateRangeF: TRadioButton
      Left = 116
      Top = 16
      Width = 93
      Height = 17
      Caption = 'Period to date'
      TabOrder = 1
      OnClick = RBDateAllClick
    end
    object RBDateRangeA: TRadioButton
      Left = 232
      Top = 16
      Width = 81
      Height = 17
      Caption = 'Time Period'
      TabOrder = 2
      OnClick = RBDateAllClick
    end
    object DTPDTakenFrom: TDateTimePicker
      Left = 238
      Top = 49
      Width = 85
      Height = 21
      Date = 39542.430481226850000000
      Format = 'dd/MM/yyyy'
      Time = 39542.430481226850000000
      Color = 10682367
      TabOrder = 3
    end
    object DTPDTakenTo: TDateTimePicker
      Left = 238
      Top = 89
      Width = 85
      Height = 21
      Date = 39542.430481226850000000
      Format = 'dd/MM/yyyy'
      Time = 39542.430481226850000000
      Color = 10682367
      TabOrder = 4
    end
    object CmBRangeF: TComboBox
      Left = 75
      Top = 48
      Width = 100
      Height = 21
      Style = csDropDownList
      Color = 10682367
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 5
      Text = 'Today'
      OnChange = CmBRangeFChange
      Items.Strings = (
        'Today'
        'Week to date'
        'Month to date'
        'Quarter to date'
        'Year to date'
        '2 Years to date'
        '3 Years to date')
    end
  end
  object ChBOpenSelectedFlag: TCheckBox
    Left = 40
    Top = 528
    Width = 425
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'Open up to 4 filtered objects'
    TabOrder = 7
  end
  object ActionList1: TActionList
    Left = 352
    Top = 475
    object aResetChart: TAction
      Caption = '&Reset Chart'
      OnExecute = aResetChartExecute
    end
    object aCLoseOK: TAction
      Caption = '&OK'
      OnExecute = aCLoseOKExecute
    end
    object aCloseCancel: TAction
      Caption = '&Cancel'
      OnExecute = aCloseCancelExecute
    end
    object aSave: TAction
      Caption = 'Save'
      OnExecute = aSaveExecute
    end
    object aAdd: TAction
      Caption = 'New'
      OnExecute = aAddExecute
    end
    object aDelete: TAction
      Caption = 'Delete'
      OnExecute = aDeleteExecute
    end
  end
end
