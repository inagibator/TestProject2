inherited K_FormCMStudyTemplatesSetup: TK_FormCMStudyTemplatesSetup
  Left = 550
  Top = 458
  Width = 384
  Height = 576
  Caption = 'Study Templates Setup'
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 371
    Top = 537
    Width = 13
    Height = 15
  end
  object TemplatesPanel: TPanel
    Left = 8
    Top = 8
    Width = 363
    Height = 406
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 1
    object Splitter1: TSplitter
      Left = 0
      Top = 297
      Width = 363
      Height = 5
      Cursor = crVSplit
      Align = alTop
    end
    object GBTemplatesVis: TGroupBox
      Left = 0
      Top = 0
      Width = 363
      Height = 297
      Align = alTop
      Caption = '  Visible Templates  '
      TabOrder = 0
      inline ThumbsVisRFrame: TN_Rast1Frame
        Left = 2
        Top = 15
        Width = 359
        Height = 280
        HelpType = htKeyword
        Align = alClient
        Constraints.MinHeight = 56
        Constraints.MinWidth = 56
        Color = clBtnFace
        ParentColor = False
        TabOrder = 0
        inherited PaintBox: TPaintBox
          Width = 343
          Height = 264
        end
        inherited HScrollBar: TScrollBar
          Top = 264
          Width = 359
        end
        inherited VScrollBar: TScrollBar
          Left = 343
          Height = 264
        end
      end
    end
    object GBTemplatesHid: TGroupBox
      Left = 0
      Top = 302
      Width = 363
      Height = 104
      Align = alClient
      Caption = '  Hidden Temlates  '
      TabOrder = 1
      inline ThumbsHidRFrame: TN_Rast1Frame
        Left = 2
        Top = 15
        Width = 359
        Height = 87
        HelpType = htKeyword
        Align = alClient
        Constraints.MinHeight = 56
        Constraints.MinWidth = 56
        Color = clBtnFace
        ParentColor = False
        TabOrder = 0
        inherited PaintBox: TPaintBox
          Width = 343
          Height = 71
        end
        inherited HScrollBar: TScrollBar
          Top = 71
          Width = 359
        end
        inherited VScrollBar: TScrollBar
          Left = 343
          Height = 71
        end
      end
    end
  end
  object CtrlsPanel: TPanel
    Left = 7
    Top = 418
    Width = 363
    Height = 119
    Anchors = [akLeft, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 2
    DesignSize = (
      363
      119)
    object BtTempLoad: TButton
      Left = 256
      Top = 19
      Width = 105
      Height = 23
      Action = aLoad
      Anchors = [akTop, akRight]
      TabOrder = 0
    end
    object BtOK: TButton
      Left = 256
      Top = 51
      Width = 105
      Height = 23
      Anchors = [akTop, akRight]
      Caption = 'OK'
      ModalResult = 1
      TabOrder = 1
    end
    object BtCancel: TButton
      Left = 256
      Top = 83
      Width = 105
      Height = 23
      Anchors = [akTop, akRight]
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 2
    end
    object GBSelectedActs: TGroupBox
      Left = 0
      Top = 0
      Width = 241
      Height = 117
      Caption = '  Current selected template  '
      TabOrder = 3
      object BtTempHide: TButton
        Left = 8
        Top = 19
        Width = 105
        Height = 23
        Action = aHide
        TabOrder = 0
      end
      object BtTempBeforeAll: TButton
        Left = 128
        Top = 19
        Width = 105
        Height = 23
        Action = aPutBeforeAll
        TabOrder = 1
      end
      object BtTempDelete: TButton
        Left = 8
        Top = 51
        Width = 105
        Height = 23
        Action = aDelete
        TabOrder = 2
      end
      object BtTempAfterAll: TButton
        Left = 128
        Top = 51
        Width = 105
        Height = 23
        Action = aPutAfterAll
        TabOrder = 3
      end
      object BtTempUnload: TButton
        Left = 8
        Top = 83
        Width = 105
        Height = 23
        Action = aUnload
        TabOrder = 4
      end
    end
  end
  object ActionList: TActionList
    Left = 239
    Top = 410
    object aUnload: TAction
      Caption = 'Unload'
    end
    object aPutBeforeAll: TAction
      Caption = 'Put before all visible'
    end
    object aPutAfterAll: TAction
      Caption = 'Put after all visible'
    end
    object aDelete: TAction
      Caption = 'Delete'
    end
    object aHide: TAction
      Caption = 'Hide'
    end
    object aLoad: TAction
      Caption = 'Load template'
    end
  end
end
