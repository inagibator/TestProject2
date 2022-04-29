inherited K_FormCMSetSlidesAttrs2: TK_FormCMSetSlidesAttrs2
  Left = 291
  Top = 98
  Width = 803
  Height = 602
  Caption = 'Slides properties'
  FormStyle = fsStayOnTop
  KeyPreview = True
  OldCreateOrder = True
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  DesignSize = (
    787
    563)
  PixelsPerInch = 96
  TextHeight = 13
  object LbDiagnoses: TLabel [0]
    Left = 10
    Top = 225
    Width = 50
    Height = 13
    Caption = '&Diagnoses'
  end
  object LbMediaType: TLabel [1]
    Left = 10
    Top = 178
    Width = 74
    Height = 13
    Caption = '&Media Category'
  end
  object LbDTTaken: TLabel [2]
    Left = 12
    Top = 10
    Width = 85
    Height = 13
    Caption = 'Date/Time &Taken'
  end
  object LbVolt: TLabel [3]
    Left = 6
    Top = 94
    Width = 55
    Height = 13
    Caption = 'Voltage, kV'
  end
  object LbCur: TLabel [4]
    Left = 94
    Top = 94
    Width = 55
    Height = 13
    Caption = 'Current, mA'
  end
  object LbExpTime: TLabel [5]
    Left = 6
    Top = 134
    Width = 63
    Height = 13
    Caption = 'Exposure, ms'
  end
  object LbMod: TLabel [6]
    Left = 94
    Top = 134
    Width = 77
    Height = 13
    Caption = 'DICOM Modality'
  end
  inherited BFMinBRPanel: TPanel
    Left = 777
    Top = 552
    Width = 9
    TabOrder = 9
  end
  object BtResetChart: TButton
    Left = 425
    Top = 26
    Width = 123
    Height = 25
    Action = ResetChart
    Anchors = [akTop, akRight]
    TabOrder = 2
  end
  object MemoDiagnoses: TMemo
    Left = 6
    Top = 240
    Width = 175
    Height = 123
    Anchors = [akLeft, akTop, akRight]
    Color = 10682367
    ScrollBars = ssVertical
    TabOrder = 1
  end
  object Button1: TButton
    Left = 415
    Top = 525
    Width = 65
    Height = 25
    Action = CloseCancel
    Anchors = [akRight, akBottom]
    TabOrder = 3
  end
  object Button2: TButton
    Left = 712
    Top = 525
    Width = 73
    Height = 25
    Action = SaveSelected
    Anchors = [akRight, akBottom]
    TabOrder = 4
  end
  object CmBMediaTypes: TComboBox
    Left = 6
    Top = 194
    Width = 177
    Height = 21
    Style = csDropDownList
    Color = 10682367
    ItemHeight = 13
    TabOrder = 0
  end
  object ThumbPanel: TPanel
    Left = 6
    Top = 376
    Width = 780
    Height = 122
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvLowered
    Caption = 'ThumbPanel'
    TabOrder = 5
    inline ThumbsRFrame: TN_Rast1Frame
      Left = 1
      Top = 1
      Width = 778
      Height = 120
      HelpType = htKeyword
      Align = alClient
      Constraints.MinHeight = 104
      Constraints.MinWidth = 78
      Color = clBtnFace
      ParentColor = False
      TabOrder = 0
      inherited PaintBox: TPaintBox
        Width = 762
        Height = 105
      end
      inherited HScrollBar: TScrollBar
        Top = 105
        Width = 778
        Height = 15
      end
      inherited VScrollBar: TScrollBar
        Left = 762
        Height = 105
      end
    end
  end
  object Button3: TButton
    Left = 600
    Top = 525
    Width = 105
    Height = 25
    Action = SelectAll
    Anchors = [akRight, akBottom]
    TabOrder = 6
  end
  object Button4: TButton
    Left = 487
    Top = 525
    Width = 105
    Height = 25
    Action = DeselectAll
    Anchors = [akRight, akBottom]
    TabOrder = 7
  end
  object Button5: TButton
    Left = 343
    Top = 525
    Width = 65
    Height = 25
    Action = DeleteSelected
    Anchors = [akRight, akBottom]
    TabOrder = 8
  end
  object DTPTTaken: TDateTimePicker
    Left = 103
    Top = 28
    Width = 69
    Height = 21
    Date = 39542.430481226850000000
    Format = 'HH:mm:ss'
    Time = 39542.430481226850000000
    Color = 10682367
    DateFormat = dfLong
    Kind = dtkTime
    TabOrder = 10
  end
  object DTPDTaken: TDateTimePicker
    Left = 6
    Top = 28
    Width = 95
    Height = 21
    Date = 39542.430481226850000000
    Format = 'dd/MM/yyyy'
    Time = 39542.430481226850000000
    Color = 10682367
    TabOrder = 11
  end
  object ChBUseSlideDT: TCheckBox
    Left = 6
    Top = 52
    Width = 160
    Height = 17
    Caption = 'Use last modified date'
    TabOrder = 12
    OnClick = ChBUseSlideDTClick
  end
  object PnThumbPA: TPanel
    Left = 0
    Top = 506
    Width = 105
    Height = 57
    Anchors = [akLeft, akBottom]
    BevelOuter = bvNone
    TabOrder = 13
    object LbVProcessed: TLabel
      Left = 85
      Top = 36
      Width = 12
      Height = 13
      Alignment = taRightJustify
      Caption = '__'
    end
    object LbProcessed: TLabel
      Left = 8
      Top = 36
      Width = 53
      Height = 13
      Caption = 'Processed:'
    end
    object LbAvailable: TLabel
      Left = 8
      Top = 8
      Width = 46
      Height = 13
      Caption = 'Available:'
    end
    object LbVAvailable: TLabel
      Left = 90
      Top = 8
      Width = 6
      Height = 13
      Alignment = taRightJustify
      Caption = '_'
    end
  end
  inline CMSTeethChartFrame: TK_FrameCMTeethChart1
    Left = 186
    Top = 62
    Width = 600
    Height = 300
    Anchors = [akTop, akRight]
    TabOrder = 14
  end
  object PnFlipRotate: TPanel
    Left = 119
    Top = 511
    Width = 209
    Height = 52
    Anchors = [akLeft, akBottom]
    BevelOuter = bvNone
    Caption = 'PnFlipRotate'
    TabOrder = 15
    object FlipRotateToolBar: TToolBar
      Left = 2
      Top = -2
      Width = 205
      Height = 54
      Align = alNone
      ButtonHeight = 50
      ButtonWidth = 51
      Caption = 'FlipRotateToolBar'
      TabOrder = 0
      object ToolButton1: TToolButton
        Left = 0
        Top = 2
        Action = RotateLeft
      end
      object ToolButton2: TToolButton
        Left = 51
        Top = 2
        Action = RotateRight
      end
      object ToolButton3: TToolButton
        Left = 102
        Top = 2
        Action = Rotate180
      end
      object ToolButton4: TToolButton
        Left = 153
        Top = 2
        Action = FlipHorizontally
      end
    end
  end
  object ChBAutoOpen: TCheckBox
    Left = 6
    Top = 70
    Width = 160
    Height = 17
    Caption = 'Automatically open images'
    TabOrder = 16
    OnClick = ChBUseSlideDTClick
  end
  object EdVoltage: TEdit
    Left = 6
    Top = 110
    Width = 79
    Height = 21
    Color = 10682367
    TabOrder = 17
    OnChange = EdVoltageChange
  end
  object EdCurrent: TEdit
    Left = 94
    Top = 110
    Width = 79
    Height = 21
    Color = 10682367
    TabOrder = 18
    OnChange = EdVoltageChange
  end
  object EdExpTime: TEdit
    Left = 6
    Top = 150
    Width = 79
    Height = 21
    Color = 10682367
    TabOrder = 19
    OnChange = EdVoltageChange
  end
  object CmBModality: TComboBox
    Left = 94
    Top = 150
    Width = 79
    Height = 21
    Style = csDropDownList
    Color = 10682367
    ItemHeight = 13
    TabOrder = 20
    OnChange = CmBModalityChange
  end
  object ActionList1: TActionList
    Images = N_CMResForm.MainIcons18
    Left = 448
    Top = 454
    object ResetChart: TAction
      Caption = '&Reset Chart'
      OnExecute = ResetChartExecute
    end
    object SaveSelected: TAction
      Caption = '&Process'
      OnExecute = SaveSelectedExecute
    end
    object CloseCancel: TAction
      Caption = 'E&xit'
      OnExecute = CloseCancelExecute
    end
    object SelectAll: TAction
      Caption = 'Se&lect All'
      OnExecute = SelectAllExecute
    end
    object DeselectAll: TAction
      Caption = '&Deselect All'
      OnExecute = DeselectAllExecute
    end
    object DeleteSelected: TAction
      Caption = 'D&elete'
      OnExecute = DeleteSelectedExecute
    end
    object RotateLeft: TAction
      Caption = 'RotateLeft'
      ImageIndex = 20
      OnExecute = RotateLeftExecute
    end
    object RotateRight: TAction
      Caption = 'RotateRight'
      ImageIndex = 21
      OnExecute = RotateRightExecute
    end
    object Rotate180: TAction
      Caption = 'Rotate180'
      ImageIndex = 22
      OnExecute = Rotate180Execute
    end
    object FlipHorizontally: TAction
      Caption = 'FlipHorizontally'
      ImageIndex = 24
      OnExecute = FlipHorizontallyExecute
    end
  end
end
