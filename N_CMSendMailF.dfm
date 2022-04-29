inherited N_CMSendMailForm: TN_CMSendMailForm
  Left = 0
  Top = 219
  Caption = 'Sending an E-mail'
  ClientHeight = 343
  ClientWidth = 678
  OldCreateOrder = True
  OnShow = FormShow
  ExplicitWidth = 694
  ExplicitHeight = 382
  DesignSize = (
    678
    343)
  PixelsPerInch = 96
  TextHeight = 13
  object lbTo: TLabel [0]
    Left = 24
    Top = 19
    Width = 16
    Height = 13
    Caption = 'To:'
  end
  object lbBody: TLabel [1]
    Left = 24
    Top = 73
    Width = 27
    Height = 13
    Caption = 'Body:'
  end
  object lbCopy: TLabel [2]
    Left = 24
    Top = 46
    Width = 27
    Height = 13
    Caption = 'Copy:'
  end
  object Label1: TLabel [3]
    Left = 24
    Top = 177
    Width = 62
    Height = 13
    Caption = 'Attachments:'
  end
  object cbTotalSize: TLabel [4]
    Left = 93
    Top = 288
    Width = 48
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'Total size:'
  end
  object lbSize: TLabel [5]
    Left = 147
    Top = 288
    Width = 6
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = '0'
  end
  inherited BFMinBRPanel: TPanel
    Left = 688
    Top = 349
    BiDiMode = bdRightToLeftNoAlign
    ParentBiDiMode = False
    TabOrder = 4
    ExplicitLeft = 688
    ExplicitTop = 349
  end
  object MemoBody: TMemo
    Left = 92
    Top = 70
    Width = 579
    Height = 99
    Anchors = [akLeft, akTop, akRight]
    Color = 10682367
    TabOrder = 2
  end
  object cbTo: TComboBox
    Left = 92
    Top = 16
    Width = 579
    Height = 21
    Style = csSimple
    Anchors = [akLeft, akTop, akRight]
    Color = 10682367
    TabOrder = 0
  end
  object cbCopy: TComboBox
    Left = 92
    Top = 43
    Width = 579
    Height = 21
    Style = csSimple
    Anchors = [akLeft, akTop, akRight]
    Color = 10682367
    TabOrder = 1
  end
  object NewPanel: TPanel
    Left = 489
    Top = 175
    Width = 182
    Height = 130
    Anchors = [akTop, akRight]
    Caption = '_NewPanel'
    Locked = True
    TabOrder = 7
    inline NewRFrame: TN_Rast1Frame
      Left = 2
      Top = 2
      Width = 180
      Height = 140
      HelpType = htKeyword
      Constraints.MinHeight = 73
      Constraints.MinWidth = 73
      Color = clBtnFace
      ParentColor = False
      TabOrder = 0
      ExplicitLeft = 2
      ExplicitTop = 2
      ExplicitWidth = 180
      ExplicitHeight = 140
      inherited PaintBox: TPaintBox
        Width = 164
        Height = 124
        Constraints.MinHeight = 52
        Constraints.MinWidth = 52
        ExplicitWidth = 164
        ExplicitHeight = 124
      end
      inherited HScrollBar: TScrollBar
        Top = 124
        Width = 180
        ExplicitTop = 124
        ExplicitWidth = 180
      end
      inherited VScrollBar: TScrollBar
        Left = 164
        Height = 124
        ExplicitLeft = 164
        ExplicitHeight = 124
      end
    end
  end
  object StringGrid1: TStringGrid
    Left = 93
    Top = 175
    Width = 390
    Height = 107
    Anchors = [akLeft, akTop, akRight, akBottom]
    ColCount = 2
    FixedCols = 0
    RowCount = 2
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect]
    TabOrder = 3
    OnClick = StringGrid1Click
  end
  object bnClose: TButton
    Left = 596
    Top = 323
    Width = 75
    Height = 26
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    TabOrder = 6
    OnClick = bnCloseClick
  end
  object bnOK: TButton
    Left = 515
    Top = 323
    Width = 75
    Height = 26
    Anchors = [akRight, akBottom]
    BiDiMode = bdRightToLeft
    Caption = 'Send'
    ModalResult = 1
    ParentBiDiMode = False
    TabOrder = 5
    OnClick = bnOKClick
  end
  object IdSSLIOHandlerSocketSMTP: TIdSSLIOHandlerSocketOpenSSL
    Destination = 'outlook.office365.com:587'
    Host = 'outlook.office365.com'
    MaxLineAction = maException
    Port = 587
    DefaultPort = 0
    SSLOptions.Method = sslvSSLv23
    SSLOptions.SSLVersions = [sslvSSLv2, sslvSSLv3, sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2]
    SSLOptions.Mode = sslmUnassigned
    SSLOptions.VerifyMode = []
    SSLOptions.VerifyDepth = 0
    Left = 248
    Top = 56
  end
end
