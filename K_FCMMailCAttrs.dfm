inherited K_FormMailCommonAttrs: TK_FormMailCommonAttrs
  Left = 680
  Top = 227
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'E-mail Settings '
  ClientHeight = 346
  ClientWidth = 311
  OnCloseQuery = FormCloseQuery
  OnDestroy = FormDestroy
  ExplicitWidth = 317
  ExplicitHeight = 375
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 299
    Top = 334
    ExplicitLeft = 299
    ExplicitTop = 334
  end
  object ChBUseDefaultEmailClient: TCheckBox
    AlignWithMargins = True
    Left = 6
    Top = 6
    Width = 302
    Height = 17
    Margins.Left = 6
    Margins.Top = 6
    Align = alTop
    Caption = 'Use Windows Default E-mail Client'
    TabOrder = 1
    OnClick = ChBUseDefaultEmailClientClick
  end
  object pcAuthType: TPageControl
    Left = 0
    Top = 26
    Width = 311
    Height = 279
    ActivePage = OAuth2
    Align = alClient
    TabOrder = 2
    object tsBasicAuth: TTabSheet
      Caption = 'Basic auth'
      object GBSelfEmailClientSettings: TGroupBox
        Left = 0
        Top = 0
        Width = 303
        Height = 251
        Align = alClient
        Caption = 'Outgoing E-mail Client Settings  '
        TabOrder = 0
        DesignSize = (
          303
          251)
        object LEdServer: TLabeledEdit
          Left = 128
          Top = 24
          Width = 159
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          BiDiMode = bdLeftToRight
          Color = 10682367
          EditLabel.Width = 114
          EditLabel.Height = 13
          EditLabel.BiDiMode = bdLeftToRight
          EditLabel.Caption = 'Server Internet Address:'
          EditLabel.ParentBiDiMode = False
          LabelPosition = lpLeft
          ParentBiDiMode = False
          TabOrder = 0
        end
        object LEdPort: TLabeledEdit
          Left = 128
          Top = 56
          Width = 159
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          BiDiMode = bdLeftToRight
          Color = 10682367
          EditLabel.Width = 114
          EditLabel.Height = 13
          EditLabel.BiDiMode = bdLeftToRight
          EditLabel.Caption = 'Server Port Number:      '
          EditLabel.ParentBiDiMode = False
          LabelPosition = lpLeft
          ParentBiDiMode = False
          TabOrder = 1
          OnChange = LEdPortChange
        end
        object LEdTimeout: TLabeledEdit
          Left = 128
          Top = 120
          Width = 159
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          Color = 10682367
          EditLabel.Width = 113
          EditLabel.Height = 13
          EditLabel.Caption = 'Server Timeout (sec):    '
          LabelPosition = lpLeft
          TabOrder = 4
          OnChange = LEdTimeoutChange
        end
        object LEdSender: TLabeledEdit
          Left = 128
          Top = 216
          Width = 159
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          Color = 10682367
          EditLabel.Width = 112
          EditLabel.Height = 13
          EditLabel.Caption = 'Sender Mail Address:    '
          LabelPosition = lpLeft
          TabOrder = 7
        end
        object LEdPassword: TLabeledEdit
          Left = 128
          Top = 184
          Width = 159
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          Color = 10682367
          EditLabel.Width = 113
          EditLabel.Height = 13
          EditLabel.Caption = 'Server Password:          '
          LabelPosition = lpLeft
          PasswordChar = '#'
          TabOrder = 6
        end
        object LEdLogin: TLabeledEdit
          Left = 128
          Top = 152
          Width = 159
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          Color = 10682367
          EditLabel.Width = 111
          EditLabel.Height = 13
          EditLabel.Caption = 'Server Login:                '
          LabelPosition = lpLeft
          TabOrder = 5
        end
        object rbSSL: TRadioButton
          Left = 13
          Top = 90
          Width = 52
          Height = 17
          Caption = 'SSL'
          Checked = True
          TabOrder = 2
          TabStop = True
        end
        object rbTLS: TRadioButton
          Left = 69
          Top = 90
          Width = 51
          Height = 17
          Caption = 'TLS'
          TabOrder = 3
        end
      end
    end
    object OAuth2: TTabSheet
      Caption = 'OAuth2'
      ImageIndex = 1
      object lblProvider: TLabel
        Left = 32
        Top = 83
        Width = 42
        Height = 13
        Caption = 'Provider:'
      end
      object lblEmail: TLabel
        Left = 3
        Top = 110
        Width = 71
        Height = 13
        Caption = 'E-mail address:'
      end
      object cbProvider: TComboBox
        Left = 80
        Top = 79
        Width = 209
        Height = 22
        Style = csOwnerDrawFixed
        ItemIndex = 0
        TabOrder = 0
        Text = 'Google'
        OnChange = cbProviderChange
        Items.Strings = (
          'Google'
          'Microsoft')
      end
      object edtEmail: TEdit
        Left = 80
        Top = 107
        Width = 209
        Height = 21
        TabOrder = 1
        OnChange = edtEmailChange
      end
      object btnAuth: TButton
        Left = 80
        Top = 134
        Width = 209
        Height = 25
        Caption = 'Authenticate'
        Enabled = False
        TabOrder = 2
        OnClick = btnAuthClick
      end
    end
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 305
    Width = 311
    Height = 41
    Align = alBottom
    TabOrder = 3
    DesignSize = (
      311
      41)
    object BtCancel: TButton
      Left = 234
      Top = 10
      Width = 65
      Height = 23
      Anchors = [akRight, akBottom]
      Caption = '&Cancel'
      ModalResult = 2
      TabOrder = 0
    end
    object BtOK: TButton
      Left = 162
      Top = 10
      Width = 65
      Height = 23
      Anchors = [akRight, akBottom]
      Caption = '&OK'
      ModalResult = 1
      TabOrder = 1
    end
    object ChBUseCommonSettings: TCheckBox
      Left = 4
      Top = 16
      Width = 138
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Use Location settings'
      TabOrder = 2
      OnClick = ChBUseCommonSettingsClick
    end
  end
  object IdHTTPServer1: TIdHTTPServer
    Active = True
    Bindings = <>
    DefaultPort = 2132
    OnCommandGet = IdHTTPServer1CommandGet
    Left = 179
    Top = 72
  end
end
