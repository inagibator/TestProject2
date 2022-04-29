inherited K_FormCMChangeSlidesAttrsN2: TK_FormCMChangeSlidesAttrsN2
  Left = 699
  Top = 308
  Width = 790
  Height = 608
  BorderIcons = [biSystemMenu]
  Caption = 'Process Properties/Diagnoses'
  KeyPreview = True
  OldCreateOrder = True
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object LbDiagnoses: TLabel [0]
    Left = 10
    Top = 206
    Width = 50
    Height = 13
    Caption = '&Diagnoses'
    FocusControl = MemoDiagnoses
  end
  object LbMediaType: TLabel [1]
    Left = 10
    Top = 160
    Width = 74
    Height = 13
    Caption = '&Media Category'
    FocusControl = CmBMediaTypes
  end
  object LbDateTaken: TLabel [2]
    Left = 10
    Top = 10
    Width = 57
    Height = 13
    Caption = 'Date &Taken'
    FocusControl = DTPDTaken
  end
  object LbVolt: TLabel [3]
    Left = 6
    Top = 78
    Width = 55
    Height = 13
    Caption = 'Voltage, kV'
  end
  object LbCur: TLabel [4]
    Left = 94
    Top = 78
    Width = 55
    Height = 13
    Caption = 'Current, mA'
  end
  object LbExpTime: TLabel [5]
    Left = 6
    Top = 118
    Width = 63
    Height = 13
    Caption = 'Exposure, ms'
  end
  object LbMod: TLabel [6]
    Left = 94
    Top = 118
    Width = 77
    Height = 13
    Caption = 'DICOM Modality'
  end
  inherited BFMinBRPanel: TPanel
    Left = 762
    Top = 557
    TabOrder = 9
  end
  object BtResetChart: TButton
    Left = 180
    Top = 9
    Width = 123
    Height = 25
    Action = ResetChart
    Anchors = [akTop, akRight]
    TabOrder = 2
    Visible = False
  end
  object MemoDiagnoses: TMemo
    Left = 8
    Top = 224
    Width = 169
    Height = 101
    Anchors = [akLeft, akTop, akRight]
    Color = 10682367
    ScrollBars = ssVertical
    TabOrder = 1
  end
  object CmBMediaTypes: TComboBox
    Left = 8
    Top = 178
    Width = 169
    Height = 21
    Style = csDropDownList
    Color = 10682367
    ItemHeight = 13
    TabOrder = 0
  end
  object ThumbPanel: TPanel
    Left = 8
    Top = 336
    Width = 769
    Height = 117
    Anchors = [akLeft, akTop, akRight]
    BevelOuter = bvLowered
    Caption = 'ThumbPanel'
    TabOrder = 3
    inline ThumbsRFrame: TN_Rast1Frame
      Left = 1
      Top = 1
      Width = 767
      Height = 115
      HelpType = htKeyword
      Align = alClient
      Constraints.MinHeight = 56
      Constraints.MinWidth = 78
      Color = clBtnFace
      ParentColor = False
      TabOrder = 0
      inherited PaintBox: TPaintBox
        Width = 751
        Height = 99
      end
      inherited HScrollBar: TScrollBar
        Top = 99
        Width = 767
      end
      inherited VScrollBar: TScrollBar
        Left = 751
        Height = 99
      end
    end
  end
  object GBDetails: TGroupBox
    Left = 9
    Top = 463
    Width = 376
    Height = 101
    Anchors = [akLeft, akBottom]
    Caption = '  Details  '
    TabOrder = 4
    object LbVDurationFormat: TLabel
      Left = 312
      Top = 40
      Width = 43
      Height = 13
      Caption = '%1.f sec '
      Visible = False
    end
    object LbColorDepth: TLabel
      Left = 88
      Top = 40
      Width = 59
      Height = 13
      Caption = 'Color Depth:'
    end
    object LbVColorDepth: TLabel
      Left = 188
      Top = 40
      Width = 30
      Height = 13
      Alignment = taRightJustify
      Caption = '_4bpp'
    end
    object LbSize: TLabel
      Left = 256
      Top = 20
      Width = 23
      Height = 13
      Caption = 'Size:'
    end
    object LbVSize: TLabel
      Left = 308
      Top = 20
      Width = 36
      Height = 13
      Alignment = taRightJustify
      Caption = '_467kb'
    end
    object LbSource: TLabel
      Left = 16
      Top = 60
      Width = 37
      Height = 13
      Caption = 'Source:'
    end
    object LbVSource: TLabel
      Left = 63
      Top = 60
      Width = 38
      Height = 13
      Caption = '_X-Ray '
    end
    object LbDuration: TLabel
      Left = 256
      Top = 40
      Width = 43
      Height = 13
      Caption = 'Duration:'
    end
    object LbVDuration: TLabel
      Left = 308
      Top = 40
      Width = 50
      Height = 13
      Caption = '_2.53 sec '
    end
    object LbObjID: TLabel
      Left = 16
      Top = 20
      Width = 14
      Height = 13
      Caption = 'ID:'
    end
    object LbVObjID: TLabel
      Left = 38
      Top = 20
      Width = 36
      Height = 13
      Caption = '_84563'
    end
    object LbDims: TLabel
      Left = 89
      Top = 20
      Width = 86
      Height = 13
      Caption = 'Dimensions (HxV) '
    end
    object LbVDims: TLabel
      Left = 188
      Top = 20
      Width = 59
      Height = 13
      Caption = '_720 x 2400'
    end
    object LbDims3D: TLabel
      Left = 89
      Top = 20
      Width = 99
      Height = 13
      Caption = 'Dimensions (HxVxD) '
    end
    object LbDICOM: TLabel
      Left = 16
      Top = 80
      Width = 69
      Height = 13
      Caption = 'DICOM status:'
    end
    object LbDCMState: TLabel
      Left = 91
      Top = 80
      Width = 3
      Height = 13
    end
  end
  object Button3: TButton
    Left = 498
    Top = 503
    Width = 80
    Height = 25
    Action = ShowHistory
    Anchors = [akRight, akBottom]
    TabOrder = 5
  end
  object BtCancel: TButton
    Left = 690
    Top = 503
    Width = 80
    Height = 25
    Action = CloseCancel
    Anchors = [akRight, akBottom]
    ModalResult = 2
    TabOrder = 6
  end
  object BtLocs: TButton
    Left = 402
    Top = 503
    Width = 80
    Height = 25
    Action = ShowLocsInfo
    Anchors = [akRight, akBottom]
    TabOrder = 7
  end
  object Button4: TButton
    Left = 594
    Top = 503
    Width = 80
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 8
  end
  inline CMSTeethChartFrame: TK_FrameCMTeethChart1
    Left = 184
    Top = 26
    Width = 589
    Height = 300
    Anchors = [akTop, akRight]
    TabOrder = 10
    inherited Image1: TImage
      Width = 589
    end
  end
  object DTPDTaken: TDateTimePicker
    Left = 8
    Top = 28
    Width = 85
    Height = 21
    Date = 39542.430481226850000000
    Format = 'dd/MM/yyyy'
    Time = 39542.430481226850000000
    Color = 10682367
    TabOrder = 11
    OnChange = DTPDTakenChange
  end
  object BtDTReset: TButton
    Left = 104
    Top = 27
    Width = 55
    Height = 21
    Caption = 'Reset'
    TabOrder = 12
    OnClick = BtDTResetClick
  end
  object ChBUseDT: TCheckBox
    Left = 8
    Top = 56
    Width = 153
    Height = 17
    Caption = 'Allow Date Change'
    TabOrder = 13
    OnClick = ChBUseDTClick
  end
  object EdVoltage: TEdit
    Left = 6
    Top = 94
    Width = 79
    Height = 21
    Color = 10682367
    TabOrder = 14
    OnChange = EdVoltageChange
  end
  object EdCurrent: TEdit
    Left = 94
    Top = 94
    Width = 79
    Height = 21
    Color = 10682367
    TabOrder = 15
    OnChange = EdVoltageChange
  end
  object EdExpTime: TEdit
    Left = 6
    Top = 134
    Width = 79
    Height = 21
    Color = 10682367
    TabOrder = 16
    OnChange = EdVoltageChange
  end
  object CmBModality: TComboBox
    Left = 94
    Top = 134
    Width = 79
    Height = 21
    Style = csDropDownList
    Color = 10682367
    ItemHeight = 13
    TabOrder = 17
    OnChange = CmBModalityChange
  end
  object ActionList1: TActionList
    Left = 336
    Top = 6
    object ResetChart: TAction
      Caption = '&Reset Chart'
      OnExecute = ResetChartExecute
    end
    object CloseCancel: TAction
      Caption = 'Cancel'
      OnExecute = CloseCancelExecute
    end
    object ShowHistory: TAction
      Caption = 'Show &History'
      Hint = 'Show Object History'
      OnExecute = ShowHistoryExecute
    end
    object ShowLocsInfo: TAction
      Caption = 'Locations'
      Hint = 'Show object locations information '
      OnExecute = ShowLocsInfoExecute
    end
  end
end
