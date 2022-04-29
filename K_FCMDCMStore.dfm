inherited K_FormCMDCMStore: TK_FormCMDCMStore
  Left = 346
  Top = 530
  Width = 722
  Height = 357
  Caption = 'DICOM Store'
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 694
    Top = 306
  end
  object BtStore: TButton
    Left = 561
    Top = 289
    Width = 65
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Store'
    ModalResult = 1
    TabOrder = 1
    OnClick = BtStoreClick
  end
  object BtCancel: TButton
    Left = 634
    Top = 289
    Width = 65
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Close'
    ModalResult = 2
    TabOrder = 2
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 693
    Height = 57
    Anchors = [akLeft, akTop, akRight]
    Caption = '  DICOM Server         '
    TabOrder = 3
    object Label1: TLabel
      Left = 8
      Top = 24
      Width = 58
      Height = 13
      Caption = 'PACS AET: '
    end
    object Label2: TLabel
      Left = 160
      Top = 24
      Width = 87
      Height = 13
      Caption = 'Server IP-address:'
    end
    object Label3: TLabel
      Left = 336
      Top = 24
      Width = 94
      Height = 13
      Caption = 'Server Port number:'
    end
    object Label4: TLabel
      Left = 488
      Top = 24
      Width = 74
      Height = 13
      Caption = 'Calling AE Title:'
    end
    object StateShape: TShape
      Left = 88
      Top = 0
      Width = 16
      Height = 16
      Brush.Color = clGray
      Pen.Color = clGreen
      Shape = stCircle
    end
    object LbServerPort: TLabel
      Left = 440
      Top = 24
      Width = 38
      Height = 13
      Caption = '_SP___'
    end
    object LbServerName: TLabel
      Left = 88
      Top = 24
      Width = 63
      Height = 13
      Caption = '_SN_______'
    end
    object LbServerIP: TLabel
      Left = 256
      Top = 24
      Width = 61
      Height = 13
      Caption = '_SI-__-__-__'
    end
    object LbAppEntity: TLabel
      Left = 568
      Top = 24
      Width = 110
      Height = 13
      Caption = '_AE_______________'
    end
  end
  object PnSlides: TPanel
    Left = 8
    Top = 80
    Width = 693
    Height = 201
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvLowered
    Caption = 'PnSlides'
    TabOrder = 4
    inline ThumbsRFrame: TN_Rast1Frame
      Left = 1
      Top = 1
      Width = 691
      Height = 199
      HelpType = htKeyword
      Align = alClient
      Constraints.MinHeight = 56
      Constraints.MinWidth = 56
      Color = clBtnFace
      ParentColor = False
      TabOrder = 0
      inherited PaintBox: TPaintBox
        Width = 675
        Height = 183
      end
      inherited HScrollBar: TScrollBar
        Top = 183
        Width = 691
      end
      inherited VScrollBar: TScrollBar
        Left = 675
        Height = 183
      end
    end
  end
  object ChBRedoStore: TCheckBox
    Left = 13
    Top = 292
    Width = 97
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'Redo Store'
    TabOrder = 5
    OnClick = ChBRedoStoreClick
  end
end
