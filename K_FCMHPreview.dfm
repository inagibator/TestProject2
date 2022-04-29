inherited K_FormCMHPreview: TK_FormCMHPreview
  Left = 200
  Top = 116
  Width = 581
  Height = 577
  Caption = 'Preview'
  FormStyle = fsStayOnTop
  OldCreateOrder = True
  Position = poDefault
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter [0]
    Left = 0
    Top = 425
    Width = 565
    Height = 3
    Cursor = crVSplit
    Align = alBottom
  end
  inherited BFMinBRPanel: TPanel
    Left = 561
    Top = 531
  end
  object ThumbPanel: TPanel
    Left = 0
    Top = 428
    Width = 565
    Height = 110
    Align = alBottom
    BevelOuter = bvLowered
    Caption = 'ThumbPanel'
    Constraints.MinHeight = 110
    TabOrder = 1
    inline ThumbsRFrame: TN_Rast1Frame
      Left = 24
      Top = 1
      Width = 517
      Height = 108
      HelpType = htKeyword
      Align = alClient
      Constraints.MinHeight = 104
      Constraints.MinWidth = 78
      Color = clBtnFace
      ParentColor = False
      TabOrder = 0
      inherited PaintBox: TPaintBox
        Width = 501
        Height = 93
      end
      inherited HScrollBar: TScrollBar
        Top = 93
        Width = 517
        Height = 15
      end
      inherited VScrollBar: TScrollBar
        Left = 501
        Height = 93
      end
    end
    object Panel1: TPanel
      Left = 541
      Top = 1
      Width = 23
      Height = 108
      Align = alRight
      BevelOuter = bvNone
      Caption = 'Panel1'
      TabOrder = 1
      DesignSize = (
        23
        108)
      object BtNext: TButton
        Left = 0
        Top = 2
        Width = 23
        Height = 106
        Action = aSelectNext
        Anchors = [akTop, akRight, akBottom]
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -19
        Font.Name = 'Microsoft Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
      end
    end
    object Panel2: TPanel
      Left = 1
      Top = 1
      Width = 23
      Height = 108
      Align = alLeft
      BevelOuter = bvNone
      Caption = 'Panel2'
      TabOrder = 2
      DesignSize = (
        23
        108)
      object BtPrev: TButton
        Left = 0
        Top = 2
        Width = 23
        Height = 106
        Action = aSelectPrev
        Anchors = [akLeft, akTop, akBottom]
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -19
        Font.Name = 'Microsoft Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
      end
    end
  end
  object ImgPanel: TPanel
    Left = 0
    Top = 0
    Width = 565
    Height = 425
    Align = alClient
    BevelOuter = bvLowered
    TabOrder = 2
    inline ImgRFrame: TN_Rast1Frame
      Left = 1
      Top = 1
      Width = 563
      Height = 423
      HelpType = htKeyword
      Align = alClient
      Anchors = [akLeft, akRight, akBottom]
      Constraints.MinHeight = 56
      Constraints.MinWidth = 56
      Color = clBtnFace
      ParentColor = False
      TabOrder = 0
      inherited PaintBox: TPaintBox
        Width = 547
        Height = 407
        Anchors = [akLeft, akRight, akBottom]
      end
      inherited HScrollBar: TScrollBar
        Top = 407
        Width = 563
      end
      inherited VScrollBar: TScrollBar
        Left = 547
        Height = 407
      end
    end
  end
  object ActionList1: TActionList
    Left = 80
    Top = 312
    object aSelectPrev: TAction
      Caption = '<'
      OnExecute = aSelectPrevExecute
    end
    object aSelectNext: TAction
      Caption = '>'
      OnExecute = aSelectNextExecute
    end
  end
  object Timer: TTimer
    Enabled = False
    Interval = 10
    OnTimer = TimerTimer
    Left = 112
    Top = 312
  end
end
