object CMSuiteService: TCMSuiteService
  OldCreateOrder = False
  OnDestroy = ServiceDestroy
  DisplayName = 'CMSuite service'
  Interactive = True
  OnContinue = ServiceContinue
  OnExecute = ServiceExecute
  OnPause = ServicePause
  OnStart = ServiceStart
  OnStop = ServiceStop
  Height = 150
  Width = 215
end
