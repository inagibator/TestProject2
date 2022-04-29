inherited N_CMAboutForm: TN_CMAboutForm
  Left = 712
  Top = 160
  BorderStyle = bsSingle
  Caption = 'About %s'
  ClientHeight = 645
  ClientWidth = 399
  OldCreateOrder = True
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object LbVersion: TLabel [0]
    Left = 84
    Top = 99
    Width = 209
    Height = 20
    Alignment = taCenter
    AutoSize = False
    Caption = 'Centaur Media Suite SQL'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Image1: TImage [1]
    Left = 0
    Top = 0
    Width = 399
    Height = 95
    Align = alTop
  end
  object Label1: TLabel [2]
    Left = 301
    Top = 101
    Width = 78
    Height = 16
    Caption = '   Version 4'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object BuildLabel: TLabel [3]
    Left = 315
    Top = 139
    Width = 79
    Height = 13
    Alignment = taRightJustify
    Caption = '_uild   03.012.00'
  end
  object LCopyRight: TLabel [4]
    Left = 88
    Top = 123
    Width = 115
    Height = 13
    Caption = 'Copyright '#169' 2006-%s %s'
  end
  object ReleaseDateLabel: TLabel [5]
    Left = 287
    Top = 154
    Width = 107
    Height = 13
    Alignment = taRightJustify
    Caption = '_released 06/09/2008'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object Image2: TImage [6]
    Left = 0
    Top = 95
    Width = 81
    Height = 77
  end
  object CNLabel: TLabel [7]
    Left = 8
    Top = 607
    Width = 76
    Height = 13
    Caption = 'Computer Name'
  end
  inherited BFMinBRPanel: TPanel
    Left = 389
    Top = 635
    TabOrder = 4
  end
  object BtClose: TButton
    Left = 302
    Top = 607
    Width = 67
    Height = 30
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 0
  end
  object GroupBox1: TGroupBox
    Left = 5
    Top = 183
    Width = 390
    Height = 47
    Caption = ' Publisher '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 1
    object EdPublisher: TEdit
      Left = 94
      Top = 14
      Width = 265
      Height = 24
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      TabOrder = 0
      Text = '  Centaur Software Development Company'
    end
  end
  object GroupBox2: TGroupBox
    Left = 5
    Top = 235
    Width = 390
    Height = 161
    Caption = ' Contact Information '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 2
    object Label7: TLabel
      Left = 12
      Top = 50
      Width = 54
      Height = 13
      Caption = 'Telephone '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object Label12: TLabel
      Left = 12
      Top = 77
      Width = 25
      Height = 13
      Caption = 'Email'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object Label13: TLabel
      Left = 12
      Top = 104
      Width = 36
      Height = 13
      Caption = 'Internet'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object Label14: TLabel
      Left = 214
      Top = 48
      Width = 17
      Height = 13
      Caption = 'Fax'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object Label15: TLabel
      Left = 15
      Top = 20
      Width = 38
      Height = 13
      Caption = 'Address'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object Label2: TLabel
      Left = 11
      Top = 132
      Width = 110
      Height = 13
      Caption = 'Customer Reference # '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object EdFax: TEdit
      Left = 238
      Top = 43
      Width = 143
      Height = 24
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      TabOrder = 0
      Text = ' +61-2-9213-5020'
    end
    object EdEmail: TEdit
      Left = 72
      Top = 70
      Width = 310
      Height = 24
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      TabOrder = 1
      Text = '  techsupport@centaursoftware.com'
    end
    object EdInternet: TEdit
      Left = 72
      Top = 98
      Width = 310
      Height = 24
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      TabOrder = 2
      Text = '  www.centaursoftware.com'
    end
    object EdPhone: TEdit
      Left = 72
      Top = 43
      Width = 119
      Height = 24
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      TabOrder = 3
      Text = ' +61-2-9213-5000'
    end
    object EdAddress: TEdit
      Left = 72
      Top = 16
      Width = 309
      Height = 24
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 4
      Text = ' PO Box 2313 Strawberry Hills, NSW 2012, Australia'
    end
    object EdCustomerRefNum: TEdit
      Left = 129
      Top = 126
      Width = 253
      Height = 24
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      TabOrder = 5
      Text = '1234567890'
    end
  end
  object GroupBox3: TGroupBox
    Left = 5
    Top = 402
    Width = 390
    Height = 199
    Caption = ' Credits '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 3
    object LCredits1: TLabel
      Left = 214
      Top = 20
      Width = 170
      Height = 26
      AutoSize = False
      Caption = 'Director, Original idea, Designer, Analyst'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      WordWrap = True
    end
    object LCredits2: TLabel
      Left = 214
      Top = 55
      Width = 170
      Height = 26
      AutoSize = False
      Caption = 'Director, Designer'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      WordWrap = True
    end
    object LCredits4: TLabel
      Left = 214
      Top = 125
      Width = 170
      Height = 26
      AutoSize = False
      Caption = 'System Architect, Programmer'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      WordWrap = True
    end
    object LCredits5: TLabel
      Left = 214
      Top = 160
      Width = 170
      Height = 26
      AutoSize = False
      Caption = 'System Architect, Programmer'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      WordWrap = True
    end
    object LCredits3: TLabel
      Left = 214
      Top = 90
      Width = 170
      Height = 26
      AutoSize = False
      Caption = 'Director, Global Sales, Business Development'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      WordWrap = True
    end
    object EdCredits1: TEdit
      Left = 5
      Top = 21
      Width = 199
      Height = 24
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      TabOrder = 0
      Text = ' Dr. Frank Papadopoulos, BDS'
    end
    object Edit8: TEdit
      Left = 5
      Top = 56
      Width = 199
      Height = 24
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      TabOrder = 1
      Text = ' Dr. Yuri Tsimbler, PhD'
    end
    object Edit9: TEdit
      Left = 5
      Top = 126
      Width = 199
      Height = 24
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      TabOrder = 2
      Text = ' Dr. Nikita Bogomolov, PhD'
    end
    object Edit10: TEdit
      Left = 5
      Top = 161
      Width = 199
      Height = 24
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      TabOrder = 3
      Text = ' Dr. Alexander Kovalev, PhD'
    end
    object Edit11: TEdit
      Left = 5
      Top = 91
      Width = 199
      Height = 24
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      TabOrder = 4
      Text = ' Michael Sokol, B.Sc '
    end
  end
end
