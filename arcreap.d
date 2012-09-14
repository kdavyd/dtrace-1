#!/usr/sbin/dtrace -s

fbt::arc_kmem_reap_now:entry
{
    self->start[probefunc] = timestamp;
}

fbt::arc_adjust:entry
{
    self->start[probefunc] = timestamp;
    self->inadjust = 1;
}

fbt::arc_evict:entry
/self->inadjust/
{
    self->start[probefunc] = timestamp;
}

fbt::arc_shrink:entry
{
    trace("called");
}

fbt::arc_kmem_reap_now:return,
fbt::arc_adjust:return,
fbt::arc_evict:return
/self->start[probefunc]/
{
    printf("%Y %d ms", walltimestamp,
        (timestamp - self->start[probefunc]) / 1000000);
    self->start[probefunc] = 0;
}
