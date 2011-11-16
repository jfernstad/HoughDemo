/*
 * ArrayList.h
 * by James Lawton
 *
 * The contents of this file are hereby released into the public domain,
 * to be used for any application, without restriction. No warranty is
 * provided. Use at your own risk.
 */

#include <sys/types.h> /* size_t */

typedef struct _ArrayList ArrayList;
typedef struct _ArrayListIter ArrayListIter;

/**
 * Create a new ArrayList. This must be balanced by a call to
 * ArrayListDestroy to avoid memory leaks.
 */
ArrayList * ArrayListCreate(size_t elemSize, size_t elemsPerNode);
/**
 * Allow for reference counting - NOT thread safe
 */
void ArrayListRetain(ArrayList* lst);
/**
 * Free all of the memory associated with an ArrayList, previously
 * created by ArrayListCreate. All elements stored in the list will
 * immediately be invalid, as will the list itself. 
 */
void ArrayListDestroy(ArrayList * lst);
/**
 * Empty the list, but don't free the resources, so it can be reused.
 * Useful if you're about to create another list of a similar or larger
 * size.
 */
void ArrayListEmpty(ArrayList * lst);
/**
 * Append a new element to an ArrayList. The returned memory is not
 * guaranteed to be zeroed.
 */
void * ArrayListAllocElement(ArrayList * lst);
/**
 * Get the number of elements currently stored in the array.
 */
size_t ArrayListElementCount(ArrayList * lst);
/**
 * Get an element from a specific location in the array. `index'
 * should be less than the number of elements on the array.
 * Returns NULL on an error.
 * If you're accessing all of the array elements sequentially,
 * consider using an iterator instead.
 */
void * ArrayListElementAtIndex(ArrayList * lst, size_t index);
/**
 * Get the last element appended to the array. NULL if the array
 * is empty.
 */
void * ArrayListLastElement(ArrayList * lst);

/**
 * Create an iterator pointing to the beginning of an ArrayList. You
 * should not destroy the list while iterating. The iterator will not
 * retain its list. This call should be balanced with ArrayListIterDestroy.
 */
ArrayListIter * ArrayListIterCreate(ArrayList * lst);
/**
 * Free all of the resources accosiated with an iterator, previously created
 * by ArrayListIterCreate. The iterator will immediately be invalid.
 */
void ArrayListIterDestroy(ArrayListIter * iter);
/**
 * Get the next element from the list. This will return NULL after the last
 * element has been returned.
 */
void * ArrayListIterStep(ArrayListIter * iter);
/**
 * Start iterating from the beginning of the list again.
 */
void ArrayListIterReset(ArrayListIter * iter);
