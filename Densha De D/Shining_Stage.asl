// Version 1.0.0 by Jugachi with the help of just-ero
// https://github.com/just-ero/asl-help/

state("電車でＤ ShiningStage")
{

}

startup
{
  Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
  vars.AutoSplitterType = vars.Helper.Define(@"
    using System.Runtime.InteropServices;
    [StructLayout(LayoutKind.Explicit)]
    public struct AutoSplitter {
      [FieldOffset(0x10)] public int StoryStart;
      [FieldOffset(0x14)] public int BtlStart;
      [FieldOffset(0x18)] public int BtlEnd;
      [FieldOffset(0x1C)] public int StoryEnd;
    }
    ");
}

init
{
  vars.Helper.TryLoad = (Func<dynamic, bool>)(mono =>
  {
    var btlIndex = mono.Make<int>("cGameMgr", "mLiveSplit", "BtlIndex");
    var autoSplitters = mono.MakeArray<IntPtr>("cGameMgr", "mLiveSplit", "mSplitter");

    vars.btlIndex = btlIndex;
    vars.GetCurrentAutoSplitterData = (Func<dynamic>)(() =>
    {
      btlIndex.Update(game);
      autoSplitters.Update(game);

      return vars.Helper.ReadCustom(vars.AutoSplitterType, autoSplitters.Current[btlIndex.Current]);
    });

    return true;
  });
}

update
{
  current.btlIndex = vars.btlIndex.Current;
  current.Data = vars.GetCurrentAutoSplitterData();
  current.BtlStart = current.Data.BtlStart;
  current.BtlEnd = current.Data.BtlEnd;
}

start
{
  return current.btlIndex == 0 && current.BtlStart == 1 && current.BtlEnd == 0;
}

split
{
  return current.BtlEnd == 1 && old.BtlEnd == 0;
}

isLoading
{
  return current.BtlStart == 0 || current.BtlEnd == 1;
}