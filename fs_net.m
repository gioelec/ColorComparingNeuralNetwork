%defines the network
function perf = fs_net(x,t)
    hiddenLayerSize = 3;
    net = fitnet(hiddenLayerSize);
    net.divideParam.trainRatio = 70/100;
    net.divideParam.valRatio = 15/100;
    net.divideParam.testRatio = 15/100;
    xx = x.';
    tt = t.';
    [net, tr] = train(net, xx, tt);
    y = net(xx);
    perf = perform(net, tt, y);
end