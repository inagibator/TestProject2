inherited K_FormCMExportSlides: TK_FormCMExportSlides
  Left = 262
  Top = 386
  BorderStyle = bsSingle
  Caption = 'Export'
  ClientHeight = 286
  ClientWidth = 519
  OldCreateOrder = True
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  ExplicitWidth = 525
  ExplicitHeight = 315
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 509
    Top = 276
    TabOrder = 4
    ExplicitLeft = 509
    ExplicitTop = 276
  end
  object GBAll: TGroupBox
    Left = 8
    Top = 8
    Width = 505
    Height = 233
    Anchors = [akLeft, akTop, akRight]
    Caption = '  Current Export Folder  '
    TabOrder = 0
    DesignSize = (
      505
      233)
    inline PathNameFrame: TK_FPathNameFrame
      Tag = 161
      Left = 8
      Top = 16
      Width = 481
      Height = 24
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
      ExplicitLeft = 8
      ExplicitTop = 16
      ExplicitWidth = 481
      inherited LbPathName: TLabel
        Left = 7
        Width = 28
        ExplicitLeft = 7
        ExplicitWidth = 28
      end
      inherited mbPathName: TComboBox
        Width = 408
        Color = 10682367
        ExplicitWidth = 408
      end
      inherited bnBrowse_1: TButton
        Left = 456
        Width = 25
        ExplicitLeft = 456
        ExplicitWidth = 25
      end
    end
    object GBFtypes: TGroupBox
      Left = 16
      Top = 56
      Width = 185
      Height = 153
      Caption = '  Export Image file(s) type  '
      TabOrder = 1
      object RBJPEG: TRadioButton
        Left = 16
        Top = 20
        Width = 113
        Height = 17
        Caption = 'JPEG'
        TabOrder = 0
        OnClick = RBJPEGClick
      end
      object RBTIFF: TRadioButton
        Tag = 1
        Left = 16
        Top = 40
        Width = 113
        Height = 17
        Caption = 'TIFF'
        TabOrder = 1
        OnClick = RBJPEGClick
      end
      object RBBMP: TRadioButton
        Tag = 2
        Left = 16
        Top = 60
        Width = 113
        Height = 17
        Caption = 'BMP'
        TabOrder = 2
        OnClick = RBJPEGClick
      end
      object RBPNG: TRadioButton
        Tag = 3
        Left = 16
        Top = 80
        Width = 113
        Height = 17
        Caption = 'PNG'
        TabOrder = 3
        OnClick = RBJPEGClick
      end
      object RBDICOM: TRadioButton
        Tag = 4
        Left = 16
        Top = 100
        Width = 113
        Height = 17
        Caption = 'DICOM'
        TabOrder = 4
        OnClick = RBJPEGClick
      end
      object RBDICOMDIR: TRadioButton
        Tag = 5
        Left = 16
        Top = 120
        Width = 113
        Height = 17
        Caption = 'DICOMDIR'
        TabOrder = 5
        OnClick = RBJPEGClick
      end
    end
    object GBExportInfo: TGroupBox
      Left = 216
      Top = 56
      Width = 273
      Height = 153
      Caption = '  Export Information  '
      TabOrder = 2
      DesignSize = (
        273
        153)
      object Bevel1: TBevel
        Left = 16
        Top = 21
        Width = 241
        Height = 27
        Anchors = [akLeft, akTop, akRight]
        Shape = bsFrame
      end
      object Bevel2: TBevel
        Left = 16
        Top = 71
        Width = 241
        Height = 27
        Anchors = [akLeft, akTop, akRight]
        Shape = bsFrame
        Visible = False
      end
      object Bevel3: TBevel
        Left = 16
        Top = 46
        Width = 241
        Height = 27
        Anchors = [akLeft, akTop, akRight]
        Shape = bsFrame
      end
      object Label1: TLabel
        Left = 16
        Top = 106
        Width = 44
        Height = 13
        Caption = 'Progress:'
      end
      object Label2: TLabel
        Left = 24
        Top = 27
        Width = 111
        Height = 13
        Caption = 'Total number of objects'
      end
      object LbFNum: TLabel
        Left = 192
        Top = 27
        Width = 56
        Height = 13
        Alignment = taRightJustify
        Anchors = [akTop, akRight]
        AutoSize = False
        Caption = '__'
      end
      object Label3: TLabel
        Left = 24
        Top = 76
        Width = 142
        Height = 13
        Caption = #1053#1077#1086#1073#1093#1086#1076#1080#1084#1086#1077' '#1087#1088#1086#1089#1090#1088#1072#1085#1089#1090#1074#1086
        Visible = False
      end
      object LbSpace: TLabel
        Left = 192
        Top = 79
        Width = 56
        Height = 13
        Alignment = taRightJustify
        Anchors = [akTop, akRight]
        AutoSize = False
        Caption = '__'
        Visible = False
      end
      object Label5: TLabel
        Left = 24
        Top = 51
        Width = 76
        Height = 13
        Caption = 'Space available'
      end
      object LbSpaceFree: TLabel
        Left = 192
        Top = 51
        Width = 56
        Height = 13
        Alignment = taRightJustify
        Anchors = [akTop, akRight]
        AutoSize = False
        Caption = '__'
      end
      object Label4: TLabel
        Left = 96
        Top = 106
        Width = 133
        Height = 13
        Caption = 'Number of exported objects:'
      end
      object LbCurFNum: TLabel
        Left = 235
        Top = 106
        Width = 19
        Height = 13
        Alignment = taRightJustify
        AutoSize = False
        Caption = '_'
      end
      object PBProgress: TProgressBar
        Left = 16
        Top = 122
        Width = 241
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 0
      end
    end
  end
  object ChBAnnot: TCheckBox
    Left = 16
    Top = 254
    Width = 345
    Height = 17
    Caption = 'Export original object(s)'
    TabOrder = 1
  end
  object BtCancel: TButton
    Left = 445
    Top = 253
    Width = 65
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object BtOK: TButton
    Left = 376
    Top = 253
    Width = 65
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    TabOrder = 3
    OnClick = BtOKClick
  end
end
