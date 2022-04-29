object N_CML2Form: TN_CML2Form
  Left = 481
  Top = 128
  Width = 422
  Height = 351
  Caption = 'N_CML2Form'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 406
    Height = 312
    ActivePage = Other
    Align = alClient
    TabOrder = 0
    object TWAIN: TTabSheet
      Caption = 'TWAIN'
      object LLLErrorLoading1: TLabel
        Left = 4
        Top = 6
        Width = 63
        Height = 13
        Caption = 'Error Loading'
      end
      object LLLNotPluggedIn1: TLabel
        Left = 4
        Top = 18
        Width = 190
        Height = 13
        Caption = 'Capture device "%s"/#is not plugged in.'
      end
    end
    object Other: TTabSheet
      Caption = 'Other'
      ImageIndex = 1
      object LLLOtherFormCaption: TLabel
        Left = 4
        Top = 6
        Width = 95
        Height = 13
        Caption = '"%s" X-Ray Capture'
      end
      object LLLOther3Disconnected: TLabel
        Left = 3
        Top = 25
        Width = 66
        Height = 13
        Caption = 'Disconnected'
      end
      object LLLOther3Ready: TLabel
        Left = 3
        Top = 40
        Width = 31
        Height = 13
        Caption = 'Ready'
      end
      object LLLOther3Scanning: TLabel
        Left = 3
        Top = 54
        Width = 45
        Height = 13
        Caption = 'Scanning'
      end
      object LLLOther3Error: TLabel
        Left = 3
        Top = 67
        Width = 22
        Height = 13
        Caption = 'Error'
      end
      object LLLOther3Closing: TLabel
        Left = 3
        Top = 81
        Width = 46
        Height = 13
        Caption = 'Closing ...'
      end
      object LLLOther4Processing: TLabel
        Left = 4
        Top = 100
        Width = 52
        Height = 13
        Caption = 'Processing'
      end
      object LLLOther4Ready: TLabel
        Left = 5
        Top = 114
        Width = 67
        Height = 13
        Caption = 'Sensor Ready'
      end
    end
    object Video: TTabSheet
      Caption = 'Video'
      ImageIndex = 2
      object LLLVideoNumCaptured: TLabel
        Left = 10
        Top = 5
        Width = 100
        Height = 13
        Caption = 'Stills: %d    Video: %d'
      end
      object LLLDirectShowError1: TLabel
        Left = 10
        Top = 18
        Width = 143
        Height = 13
        Caption = 'DirectShow Error detected >> '
      end
      object LLLVideoSaving: TLabel
        Left = 10
        Top = 32
        Width = 51
        Height = 13
        Caption = ' Saving ... '
      end
      object LLLVideoSeconds: TLabel
        Left = 10
        Top = 46
        Width = 46
        Height = 13
        Caption = '  %5.1f  s '
      end
      object LLLVideoNotPluggedIn: TLabel
        Left = 12
        Top = 61
        Width = 267
        Height = 13
        Caption = '"%s" is not plugged in or not working properly! (Error=%d)'
      end
      object LLLVideoModeCaption: TLabel
        Left = 12
        Top = 80
        Width = 57
        Height = 13
        Caption = 'Video Mode'
      end
      object LLLVideoModeName1: TLabel
        Left = 12
        Top = 99
        Width = 36
        Height = 13
        Caption = 'Mode 1'
      end
      object LLLVideoModeName2: TLabel
        Left = 12
        Top = 118
        Width = 36
        Height = 13
        Caption = 'Mode 2'
      end
      object LLLVideoModeName3: TLabel
        Left = 12
        Top = 137
        Width = 36
        Height = 13
        Caption = 'Mode 3'
      end
    end
    object Pedal: TTabSheet
      Caption = 'FPedal'
      ImageIndex = 3
      object LLLWrongPortNum: TLabel
        Left = 4
        Top = 6
        Width = 573
        Height = 13
        Caption = 
          'You entered a wrong serial port number. It should be between 1 a' +
          'nd 127. Press OK to enter the correct serial port number.'
      end
      object LLLCOMPortError1: TLabel
        Left = 8
        Top = 21
        Width = 312
        Height = 13
        Caption = 
          'Failed to initialise serial port COM%d. Please check your hardwa' +
          're.'
      end
      object LLLReverseLR: TLabel
        Left = 7
        Top = 35
        Width = 91
        Height = 13
        Caption = 'Reverse Left/Right'
      end
      object LLLReverseAB: TLabel
        Left = 8
        Top = 48
        Width = 62
        Height = 13
        Caption = 'Reverse A/B'
      end
    end
    object tsFPBNames: TTabSheet
      Caption = 'FPBNames'
      ImageIndex = 4
      object lbComment: TLabel
        Left = 71
        Top = 5
        Width = 272
        Height = 13
        Caption = '_All FootPedals, Camera Buttons and Dental Units Names'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 16711808
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
      end
      object LLLNone: TLabel
        Left = 3
        Top = 25
        Width = 26
        Height = 13
        Caption = 'None'
      end
      object LLLKeyboardF5F6: TLabel
        Left = 3
        Top = 64
        Width = 75
        Height = 13
        Caption = 'Keyboard F5,F6'
      end
      object LLLKeyboardF7F8: TLabel
        Left = 3
        Top = 78
        Width = 75
        Height = 13
        Caption = 'Keyboard F7,F8'
      end
      object LLLDelcomfootpedal: TLabel
        Left = 3
        Top = 91
        Width = 86
        Height = 13
        Caption = 'Delcom foot pedal'
      end
      object LLLSerialFootPedal: TLabel
        Left = 3
        Top = 105
        Width = 76
        Height = 13
        Caption = 'Serial foot pedal'
      end
      object LLLVirtualDevice1: TLabel
        Left = 3
        Top = 37
        Width = 75
        Height = 13
        Caption = 'Virtual Device 1'
      end
      object LLLVirtualDevice2: TLabel
        Left = 3
        Top = 51
        Width = 75
        Height = 13
        Caption = 'Virtual Device 2'
      end
      object LLLSoproTouch: TLabel
        Left = 3
        Top = 118
        Width = 62
        Height = 13
        Caption = 'Sopro Touch'
      end
      object LLLSchickUSBCam2: TLabel
        Left = 3
        Top = 132
        Width = 88
        Height = 13
        Caption = 'Schick USB Cam2'
      end
      object LLLWin100D: TLabel
        Left = 3
        Top = 145
        Width = 48
        Height = 13
        Caption = 'Win-100D'
      end
      object LLLWin100DBDA: TLabel
        Left = 3
        Top = 159
        Width = 73
        Height = 13
        Caption = 'Win-100D-BDA'
      end
      object LLLUSBPedal: TLabel
        Left = 3
        Top = 172
        Width = 52
        Height = 13
        Caption = 'USB Pedal'
      end
      object LLLSchickUSBCam4: TLabel
        Left = 3
        Top = 185
        Width = 88
        Height = 13
        Caption = 'Schick USB Cam4'
      end
      object LLLMultiCam: TLabel
        Left = 3
        Top = 198
        Width = 76
        Height = 13
        Caption = 'MultiCam button'
      end
      object LLLDUPCS: TLabel
        Left = 3
        Top = 210
        Width = 121
        Height = 13
        Caption = 'Planmeca Compact Serial'
      end
      object LLLKeystrokes: TLabel
        Left = 3
        Top = 222
        Width = 52
        Height = 13
        Caption = 'Keystrokes'
      end
      object LLLQI: TLabel
        Left = 3
        Top = 234
        Width = 39
        Height = 13
        Caption = 'QI Optic'
      end
      object LLLDUSirona: TLabel
        Left = 3
        Top = 247
        Width = 30
        Height = 13
        Caption = 'Sirona'
      end
      object LLLMediaCamPlus: TLabel
        Left = 3
        Top = 259
        Width = 56
        Height = 13
        Caption = 'MediaCam+'
      end
    end
    object tsOther: TTabSheet
      Caption = 'Other'
      ImageIndex = 5
    end
  end
end
