#!/usr/sbin/dtrace -s

fbt::arc_kmem_reap_now:entry
{
    self->start[probefunc] = timestamp;
    self->strategy = args[0];
}

fbt::arc_adjust:entry
{
    self->start[probefunc] = timestamp;
}

fbt::arc_shrink:entry
{
    self->start[probefunc] = timestamp;
    trace("called");
}

fbt::arc_adjust:return,
fbt::arc_shrink:return
/self->start[probefunc]/
{
printf("%Y %d ms", walltimestamp,
        (timestamp - self->start[probefunc]) / 1000000);
    self->start[probefunc] = 0;
}

fbt::arc_kmem_reap_now:return
/self->start[probefunc]/
{
printf("%Y %d ms, strategy %d", walltimestamp,
        (timestamp - self->start[probefunc]) / 1000000, self->strategy);
    self->start[probefunc] = 0;
}

