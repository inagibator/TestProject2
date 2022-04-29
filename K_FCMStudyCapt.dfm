inherited K_FormCMStudyCapt: TK_FormCMStudyCapt
  Left = 856
  Top = 200
  Width = 754
  Height = 521
  Caption = 'K_FormCMStudyCapt'
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 726
    Top = 470
  end
  inline CMStudyFrame: TN_CMREdit3Frame
    Left = 2
    Top = 3
    Width = 734
    Height = 362
    Anchors = [akLeft, akTop, akRight, akBottom]
    Constraints.MinHeight = 80
    Constraints.MinWidth = 70
    Color = clBtnShadow
    ParentBackground = False
    ParentColor = False
    TabOrder = 1
    inherited FrameRightCaption: TLabel
      Left = 614
    end
    inherited FinishEditing: TSpeedButton
      Left = 713
    end
    inherited RFrame: TN_MapEdFrame
      Left = 0
      Top = 0
      Width = 734
      Height = 362
      Align = alClient
      inherited PaintBox: TPaintBox
        Width = 718
        Height = 346
        OnMouseDown = RFramePaintBoxMouseDown
      end
      inherited HScrollBar: TScrollBar
        Top = 346
        Width = 734
      end
      inherited VScrollBar: TScrollBar
        Left = 718
        Height = 346
      end
    end
  end
  object PnDevCtrlsParent: TPanel
    Left = 8
    Top = 376
    Width = 634
    Height = 79
    Anchors = [akLeft, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 2
  end
  object BtExit: TButton
    Left = 662
    Top = 432
    Width = 65
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'E&xit'
    ModalResult = 2
    TabOrder = 3
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 463
    Width = 738
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object BtPreview: TButton
    Left = 662
    Top = 400
    Width = 65
    Height = 25
    Hint = 'Preview last captured image'
    Anchors = [akRight, akBottom]
    Caption = 'Preview'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 5
    OnClick = BtPreviewClick
  end
  object ChBAutoTake: TCheckBox
    Left = 662
    Top = 376
    Width = 68
    Height = 17
    Anchors = [akRight, akBottom]
    Caption = 'Auto Take'
    TabOrder = 6
  end
  object LaunchTimer: TTimer
    Enabled = False
    Interval = 10
    OnTimer = LaunchTimerTimer
    Left = 608
    Top = 352
  end
end
