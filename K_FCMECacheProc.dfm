inherited K_FormCMECacheProc: TK_FormCMECacheProc
  Left = 385
  Top = 151
  Width = 570
  Height = 344
  BorderIcons = [biSystemMenu]
  Caption = 'Unsaved object(s) recovery'
  KeyPreview = True
  OldCreateOrder = True
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Image: TImage [0]
    Left = 16
    Top = 10
    Width = 32
    Height = 32
  end
  object Label1: TLabel [1]
    Left = 64
    Top = 10
    Width = 491
    Height = 31
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 
      'Last session of Centaur Media Suite was terminated abnormally. T' +
      'here are unsaved object(s). Please select "Save" or "Delete" but' +
      'ton below to each of the object(s). '
    WordWrap = True
  end
  inherited BFMinBRPanel: TPanel
    Left = 552
    Top = 300
    TabOrder = 7
  end
  object GBThumbnails: TGroupBox
    Left = 12
    Top = 253
    Width = 213
    Height = 48
    Anchors = [akLeft, akBottom]
    Caption = '  Thumbnails  '
    TabOrder = 2
    object LbAvailable: TLabel
      Left = 10
      Top = 18
      Width = 46
      Height = 13
      Caption = 'Available:'
    end
    object LbVAvailable: TLabel
      Left = 83
      Top = 18
      Width = 6
      Height = 13
      Alignment = taRightJustify
      Caption = '_'
    end
    object LbProcessed: TLabel
      Left = 113
      Top = 18
      Width = 53
      Height = 13
      Caption = 'Processed:'
    end
    object LbVProcessed: TLabel
      Left = 192
      Top = 18
      Width = 12
      Height = 13
      Alignment = taRightJustify
      Caption = '__'
    end
  end
  object Button1: TButton
    Left = 482
    Top = 267
    Width = 65
    Height = 25
    Action = CloseCancel
    Anchors = [akRight, akBottom]
    TabOrder = 0
  end
  object Button2: TButton
    Left = 396
    Top = 267
    Width = 81
    Height = 25
    Action = SaveSelectedFull
    Anchors = [akRight, akBottom]
    TabOrder = 1
  end
  object ThumbPanel: TPanel
    Left = 8
    Top = 144
    Width = 549
    Height = 108
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvLowered
    Caption = 'ThumbPanel'
    TabOrder = 3
    inline ThumbsRFrame: TN_Rast1Frame
      Left = 1
      Top = 1
      Width = 547
      Height = 106
      HelpType = htKeyword
      Align = alClient
      Constraints.MinHeight = 104
      Constraints.MinWidth = 78
      Color = clBtnFace
      ParentColor = False
      TabOrder = 0
      inherited PaintBox: TPaintBox
        Width = 531
        Height = 90
        OnDblClick = FullScreenExecute
      end
      inherited HScrollBar: TScrollBar
        Top = 90
        Width = 547
      end
      inherited VScrollBar: TScrollBar
        Left = 531
        Height = 90
      end
    end
  end
  object Button5: TButton
    Left = 324
    Top = 267
    Width = 65
    Height = 25
    Action = DeleteSelected
    Anchors = [akRight, akBottom]
    TabOrder = 4
  end
  object GBSlideInfo: TGroupBox
    Left = 8
    Top = 56
    Width = 547
    Height = 81
    Anchors = [akLeft, akTop, akRight]
    Caption = '  Object Properties  '
    TabOrder = 5
    DesignSize = (
      547
      81)
    object LbSlideState: TLabel
      Left = 14
      Top = 18
      Width = 523
      Height = 53
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = '_ew Image created on 12.05.2009 12:35:33'
      WordWrap = True
    end
  end
  object BtFullScreen: TButton
    Left = 232
    Top = 267
    Width = 87
    Height = 25
    Action = FullScreen
    Anchors = [akRight, akBottom]
    TabOrder = 6
  end
  object ActionList1: TActionList
    Left = 456
    Top = 22
    object CloseCancel: TAction
      Caption = 'E&xit'
      OnExecute = CloseCancelExecute
    end
    object SaveSelectedAs: TAction
      Caption = '_Save &as New'
      Hint = '_Save State as  New Object'
      OnExecute = SaveSelectedAsExecute
    end
    object DeleteSelected: TAction
      Caption = 'D&elete'
      OnExecute = DeleteSelectedExecute
    end
    object SaveSelected: TAction
      Caption = '_&Save'
      Hint = '_Save State to existing Object'
      OnExecute = SaveSelectedExecute
    end
    object SaveSelectedFull: TAction
      Caption = '&Save as new'
      OnExecute = SaveSelectedFullExecute
    end
    object FullScreen: TAction
      Caption = '&Full Screen'
      OnExecute = FullScreenExecute
    end
  end
end
