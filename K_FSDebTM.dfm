object K_FormDebParams: TK_FormDebParams
  Left = 192
  Top = 107
  Width = 277
  Height = 304
  Caption = 'Script Trace Mode Parameters'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 269
    Height = 270
    ActivePage = TabSheet2
    Align = alClient
    TabOrder = 0
    object TabSheet1: TTabSheet
      Caption = 'Trace'
      DesignSize = (
        261
        242)
      object Label2: TLabel
        Left = 8
        Top = 156
        Width = 78
        Height = 13
        Caption = 'Dump File Name'
      end
      object EdFileName: TEdit
        Left = 94
        Top = 152
        Width = 135
        Height = 21
        TabOrder = 0
      end
      object Button1: TButton
        Left = 232
        Top = 152
        Width = 20
        Height = 23
        Caption = '...'
        TabOrder = 1
        OnClick = Button1Click
      end
      object ChBShowDumpInStatusBar: TCheckBox
        Left = 8
        Top = 176
        Width = 249
        Height = 20
        Caption = 'Show Dump in StatusBar'
        TabOrder = 2
      end
      object Button2: TButton
        Left = 144
        Top = 219
        Width = 49
        Height = 21
        Anchors = [akRight, akBottom]
        Caption = 'Cansel'
        ModalResult = 2
        TabOrder = 3
      end
      object Button3: TButton
        Left = 205
        Top = 219
        Width = 49
        Height = 21
        Anchors = [akRight, akBottom]
        Caption = 'OK'
        ModalResult = 1
        TabOrder = 4
      end
      object ChBDumpInitSection: TCheckBox
        Left = 8
        Top = 192
        Width = 249
        Height = 20
        Caption = 'Dump Initialization'
        TabOrder = 5
      end
      object GroupBox1: TGroupBox
        Left = 1
        Top = 1
        Width = 259
        Height = 144
        Caption = ' Watch Window '
        TabOrder = 6
        object Label1: TLabel
          Left = 8
          Top = 16
          Width = 110
          Height = 13
          Caption = 'Capacity (rows number)'
        end
        object Label5: TLabel
          Left = 8
          Top = 40
          Width = 18
          Height = 13
          Caption = 'Left'
        end
        object Label6: TLabel
          Left = 8
          Top = 64
          Width = 19
          Height = 13
          Caption = 'Top'
        end
        object Label7: TLabel
          Left = 8
          Top = 88
          Width = 28
          Height = 13
          Caption = 'Width'
        end
        object Label8: TLabel
          Left = 8
          Top = 112
          Width = 31
          Height = 13
          Caption = 'Height'
        end
        object MEWWinCapacity: TMaskEdit
          Left = 200
          Top = 16
          Width = 40
          Height = 21
          EditMask = '999999;1; '
          MaxLength = 6
          TabOrder = 0
          Text = '      '
        end
        object MEWWinLeft: TMaskEdit
          Left = 200
          Top = 40
          Width = 40
          Height = 21
          EditMask = '999999;1; '
          MaxLength = 6
          TabOrder = 1
          Text = '      '
        end
        object MEWWinTop: TMaskEdit
          Left = 200
          Top = 64
          Width = 40
          Height = 21
          EditMask = '999999;1; '
          MaxLength = 6
          TabOrder = 2
          Text = '      '
        end
        object MEWWinWidth: TMaskEdit
          Left = 200
          Top = 88
          Width = 40
          Height = 21
          EditMask = '999999;1; '
          MaxLength = 6
          TabOrder = 3
          Text = '      '
        end
        object MEWWinHeight: TMaskEdit
          Left = 200
          Top = 112
          Width = 40
          Height = 21
          EditMask = '999999;1; '
          MaxLength = 6
          TabOrder = 4
          Text = '      '
        end
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Drawing'
      ImageIndex = 1
      DesignSize = (
        261
        242)
      object Label3: TLabel
        Left = 5
        Top = 31
        Width = 95
        Height = 13
        Caption = 'Draw window width:'
      end
      object Label4: TLabel
        Left = 5
        Top = 55
        Width = 99
        Height = 13
        Caption = 'Draw window height:'
      end
      object MaskEditDWinWidth: TMaskEdit
        Left = 112
        Top = 29
        Width = 136
        Height = 21
        EditMask = '999999;1; '
        MaxLength = 6
        TabOrder = 0
        Text = '      '
      end
      object MaskEditDWinHeight: TMaskEdit
        Left = 112
        Top = 53
        Width = 136
        Height = 21
        EditMask = '999999;1; '
        MaxLength = 6
        TabOrder = 1
        Text = '      '
      end
      object ChBShowDWindow: TCheckBox
        Left = 8
        Top = 8
        Width = 241
        Height = 17
        Caption = 'Show Drawing Window'
        TabOrder = 2
        OnClick = ChBShowDWindowClick
      end
      object Button4: TButton
        Left = 144
        Top = 219
        Width = 49
        Height = 21
        Anchors = [akRight, akBottom]
        Caption = 'Cansel'
        ModalResult = 2
        TabOrder = 3
      end
      object Button5: TButton
        Left = 205
        Top = 219
        Width = 49
        Height = 21
        Anchors = [akRight, akBottom]
        Caption = 'OK'
        ModalResult = 1
        TabOrder = 4
      end
    end
  end
  object OpenDialog1: TOpenDialog
    Left = 240
    Top = 65528
  end
end
