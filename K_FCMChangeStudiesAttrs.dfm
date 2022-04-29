inherited K_FormCMChangeStudiesAttrs: TK_FormCMChangeStudiesAttrs
  Left = 277
  Top = 96
  Width = 790
  Height = 561
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
    Top = 70
    Width = 28
    Height = 13
    Caption = '&Notes'
  end
  object LbDTTaken: TLabel [1]
    Left = 10
    Top = 8
    Width = 51
    Height = 13
    Caption = 'Date/Time'
  end
  inherited BFMinBRPanel: TPanel
    Left = 772
    Top = 517
    TabOrder = 4
  end
  object MemoDiagnoses: TMemo
    Left = 8
    Top = 88
    Width = 152
    Height = 257
    Anchors = [akLeft, akTop, akRight]
    Color = 10682367
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object ThumbPanel: TPanel
    Left = 8
    Top = 360
    Width = 769
    Height = 99
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvLowered
    Caption = 'ThumbPanel'
    TabOrder = 1
    inline ThumbsRFrame: TN_Rast1Frame
      Left = 1
      Top = 1
      Width = 767
      Height = 97
      HelpType = htKeyword
      Align = alClient
      Constraints.MinHeight = 56
      Constraints.MinWidth = 78
      Color = clBtnFace
      ParentColor = False
      TabOrder = 0
      inherited PaintBox: TPaintBox
        Width = 751
        Height = 81
      end
      inherited HScrollBar: TScrollBar
        Top = 81
        Width = 767
      end
      inherited VScrollBar: TScrollBar
        Left = 751
        Height = 81
      end
    end
  end
  object BtCancel: TButton
    Left = 690
    Top = 488
    Width = 80
    Height = 25
    Action = CloseCancel
    Anchors = [akRight, akBottom]
    ModalResult = 2
    TabOrder = 2
  end
  object Button4: TButton
    Left = 594
    Top = 488
    Width = 80
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 3
  end
  inline CMStudyFrame: TN_CMREdit3Frame
    Left = 175
    Top = 8
    Width = 600
    Height = 334
    Anchors = [akTop, akRight]
    Constraints.MinHeight = 80
    Constraints.MinWidth = 70
    Color = clBtnShadow
    ParentBackground = False
    ParentColor = False
    TabOrder = 5
    inherited FrameRightCaption: TLabel
      Left = 480
    end
    inherited FinishEditing: TSpeedButton
      Left = 579
    end
    inherited STReadOnly: TStaticText [4]
    end
    inherited RFrame: TN_MapEdFrame [5]
      Left = 0
      Top = 0
      Width = 600
      Height = 334
      Align = alClient
      inherited PaintBox: TPaintBox
        Width = 584
        Height = 318
      end
      inherited HScrollBar: TScrollBar
        Top = 318
        Width = 600
      end
      inherited VScrollBar: TScrollBar
        Left = 584
        Height = 318
      end
    end
  end
  object DTPDTaken: TDateTimePicker
    Left = 4
    Top = 26
    Width = 85
    Height = 21
    Date = 39542.430481226850000000
    Format = 'dd/MM/yyyy'
    Time = 39542.430481226850000000
    Color = 10682367
    Enabled = False
    TabOrder = 6
  end
  object DTPTTaken: TDateTimePicker
    Left = 88
    Top = 26
    Width = 69
    Height = 21
    Date = 39542.430481226850000000
    Format = 'HH:mm:ss'
    Time = 39542.430481226850000000
    Color = 10682367
    DateFormat = dfLong
    Enabled = False
    Kind = dtkTime
    TabOrder = 7
  end
  object GBStudyName: TGroupBox
    Left = 8
    Top = 469
    Width = 225
    Height = 49
    Anchors = [akLeft, akRight, akBottom]
    Caption = ' Study name (optional) '
    TabOrder = 8
    DesignSize = (
      225
      49)
    object EdStudyName: TEdit
      Left = 8
      Top = 18
      Width = 209
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
      Text = 'None'
      OnKeyUp = EdStudyNameKeyDown
    end
  end
  object GBSudyColor: TGroupBox
    Left = 242
    Top = 469
    Width = 121
    Height = 49
    Anchors = [akRight, akBottom]
    Caption = ' Colour Label '
    TabOrder = 9
    object CmBStudyColor: TComboBox
      Left = 8
      Top = 18
      Width = 105
      Height = 19
      Style = csOwnerDrawFixed
      ItemHeight = 13
      TabOrder = 0
      OnChange = CmBStudyColorChange
    end
  end
  object ActionList1: TActionList
    Left = 136
    Top = 65534
    object CloseCancel: TAction
      Caption = 'Cancel'
      OnExecute = CloseCancelExecute
    end
  end
end
