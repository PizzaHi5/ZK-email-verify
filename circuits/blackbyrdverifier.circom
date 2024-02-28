pragma circom 2.1.8;

include "@zk-email/circuits/email-verifier.circom";

// following https://prove.email/blog/twitter example
// - commented out twitter stuff, only need to verify the DKIM
template BlackByrdVerifier(max_header_bytes, max_body_bytes, n, k, pack_size) {
    signal input in_padded[max_header_bytes];
    signal input pubkey[k];
    signal input signature[k];
    signal input in_len_padded_bytes;

    // Identity commitment variables
    signal input address;
    signal input body_hash_idx;
    signal input precomputed_sha[32];
    signal input in_body_padded[max_body_bytes];
    signal input in_body_len_padded_bytes;
    //signal input blackbyrd_username_idx; //was twitter username

    signal output pubkey_hash;
    //signal output reveal_twitter_packed[max_twitter_packed_bytes];

    component EV = EmailVerifier(max_header_bytes, max_body_bytes, n, k, 0);
    EV.in_padded <== in_padded;
    EV.pubkey <== pubkey;
    EV.signature <== signature;
    EV.in_len_padded_bytes <== in_len_padded_bytes;
    EV.body_hash_idx <== body_hash_idx;
    EV.precomputed_sha <== precomputed_sha;
    EV.in_body_padded <== in_body_padded;
    EV.in_body_len_padded_bytes <== in_body_len_padded_bytes;

    pubkey_hash <== EV.pubkey_hash;

    // var max_twitter_len = 21;
    // var max_twitter_packed_bytes = count_packed(max_twitter_len, pack_size);

    // signal (twitter_regex_out, twitter_regex_reveal[max_body_bytes]) <== TwitterResetRegex(max_body_bytes)(in_body_padded);
    // signal is_found_twitter <== IsZero()(twitter_regex_out);
    // is_found_twitter === 0;

    // reveal_twitter_packed <== ShiftAndPackMaskedStr(max_body_bytes, max_twitter_len, pack_size)(twitter_regex_reveal, twitter_username_idx);
}
//2048, 65536
component main { public [ address ] } = BlackByrdVerifier(1024, 1536, 121, 17, 31);