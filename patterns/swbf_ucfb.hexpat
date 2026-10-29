#pragma author Josh Lambert
#pragma description Star Wars Battlefront munged data (.lvl, .mvs, .bnk)
#pragma magic [ 75 63 66 62 ] @ 0x00
#pragma endian little

// Munged game data of Pandemic Studios' Zero engine, as used by the PC versions of
// Star Wars: Battlefront (2004) and Star Wars: Battlefront II (2005): the .lvl archives,
// the .mvs movie archives and the common.bnk sound bank.
//
// A file is one "ucfb" chunk holding a tree of chunks. A chunk is a four-byte tag, a
// little-endian size and a body; the next chunk starts at the next 4-byte boundary, and
// zero words may sit between chunks. Most tags are four ASCII characters. In the sound and
// movie archives most tags are 32-bit FNV-1a hashes of names instead, with each byte ORed
// with 0x20 before it is hashed.
//
// Which tags hold chunks was measured on every .lvl file of the 2004 game's PC release:
// INFO holds chunks only under BARR, inst, Hint and regn, and DATA only under CSHD.
// A lvl_ sub-level starts with its name hash and the size of the chunks that follow.
// Format notes: https://github.com/centrevilletech/battlefront-eternal/blob/19ea2b38c9943ee93309a500cc1024e094374853/docs/formats.md

union Tag {
    char text[4];
    u32 value;
};

fn is_container(u32 t, u32 parent_tag) {
    if (t == 0x4f464e49)    // INFO
        return parent_tag == 0x52524142 || parent_tag == 0x74736e69 || parent_tag == 0x746e6948 || parent_tag == 0x6e676572;
    if (t == 0x41544144)    // DATA
        return parent_tag == 0x44485343;
    return
        t == 0x62666375 ||  // ucfb
        t == 0x5f4c564c ||  // LVL_
        t == 0x5f544d46 ||  // FMT_
        t == 0x45434146 ||  // FACE
        t == 0x5f786574 ||  // tex_
        t == 0x6c646f6d ||  // modl
        t == 0x6d676573 ||  // segm
        t == 0x6c656b73 ||  // skel
        t == 0x646f6d67 ||  // gmod
        t == 0x77646873 ||  // shdw
        t == 0x44485347 ||  // GSHD
        t == 0x44485343 ||  // CSHD
        t == 0x5f61617a ||  // zaa_
        t == 0x5f66617a ||  // zaf_
        t == 0x5a414646 ||  // FFAZ
        t == 0x4d544c53 ||  // SLTM
        t == 0x4a535453 ||  // STSJ
        t == 0x534b4e53 ||  // SNKS
        t == 0x534b454c ||  // LEKS
        t == 0x63746e65 ||  // entc
        t == 0x636e7077 ||  // wpnc
        t == 0x6364726f ||  // ordc
        t == 0x63707865 ||  // expc
        t == 0x5f5f7866 ||  // fx__
        t == 0x6c6c6f63 ||  // coll
        t == 0x45455254 ||  // TREE
        t == 0x6d697270 ||  // prim
        t == 0x6e726574 ||  // tern
        t == 0x53484350 ||  // PCHS
        t == 0x48435450 ||  // PTCH
        t == 0x4354504c ||  // LPTC
        t == 0x52544157 ||  // WATR
        t == 0x53545543 ||  // CUTS
        t == 0x52545543 ||  // CUTR
        t == 0x5f707270 ||  // prp_
        t == 0x646c7277 ||  // wrld
        t == 0x74736e69 ||  // inst
        t == 0x6e676572 ||  // regn
        t == 0x52524142 ||  // BARR
        t == 0x746e6948 ||  // Hint
        t == 0x48544150 ||  // PATH
        t == 0x68746170 ||  // path
        t == 0x6e616c70 ||  // plan
        t == 0x52574f4c ||  // LOWR
        t == 0x4e4d4f43 ||  // COMN
        t == 0x54415453 ||  // STAT
        t == 0x53534150 ||  // PASS
        t == 0x52444853 ||  // SHDR
        t == 0x45504950 ||  // PIPE
        t == 0x5f505356 ||  // VSP_
        t == 0x5f505350 ||  // PSP_
        t == 0x5f796b73 ||  // sky_
        t == 0x5f646e62 ||  // bnd_
        t == 0x64616f6c ||  // load
        t == 0x6766636d ||  // mcfg
        t == 0x5f646e73 ||  // snd_
        t == 0x5f73756d ||  // mus_
        t == 0x5f786666 ||  // ffx_
        t == 0x504f4353 ||  // SCOP
        t == 0x5f726373 ||  // scr_
        t == 0x6c636f4c ||  // Locl
        t == 0x746e6f66 ||  // font
        t == 0x58455446 ||  // FTEX
        t == 0x5bb97f21 ||  // StreamList
        t == 0x5f6f6d65 ||  // Stream
        t == 0x5e262256 ||  // SoundBankList
        t == 0x9a644d15 ||  // SampleBank
        t == 0x44485343;    // CSHD
};

struct Chunk {
    Tag tag;
    if (tag.value != 0) {
        u32 size;
        u64 end = $ + size;
        if (tag.value == 0x5f6c766c) {    // lvl_: a sub-level
            u32 name_hash;
            u32 chunks_size;
            Chunk chunks[while($ < end)];
        } else if (is_container(tag.value, parent.tag.value)) {
            Chunk chunks[while($ < end)];
        } else {
            u8 data[size];
        }
        padding[(4 - (size % 4)) % 4];
    }
};

struct File {
    Tag tag;
    u32 size;
    Chunk chunks[while($ < 8 + size)];
};

File file @ 0x00;
